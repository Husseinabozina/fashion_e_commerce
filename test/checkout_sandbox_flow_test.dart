import 'package:flutter_test/flutter_test.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/features/addresses/domain/usecases/get_default_address.dart';
import 'package:fashion_e_commerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/get_cart.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/clear_cart.dart';
import 'package:fashion_e_commerce/features/checkout/data/datasources/demo_checkout_data_source.dart';
import 'package:fashion_e_commerce/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/place_order_request.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/sandbox_payment.dart';
import 'package:fashion_e_commerce/features/checkout/domain/services/sandbox_payments.dart';
import 'package:fashion_e_commerce/features/checkout/domain/usecases/place_order.dart';
import 'package:fashion_e_commerce/features/checkout/domain/usecases/get_checkout_options.dart';
import 'package:fashion_e_commerce/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:fashion_e_commerce/features/orders/domain/repositories/orders_repository.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order.dart';
import 'package:fashion_e_commerce/features/promotions/domain/usecases/get_applied_promotion.dart';
import 'sandbox_payments_test.dart' show request;

class FakePayments implements SandboxPayments {
  SandboxPaymentStatus status = SandboxPaymentStatus.pending;
  bool offline = false;
  int begins = 0, checks = 0, forgotten = 0;
  String? owner;
  @override
  Future<SandboxPaymentSession> begin(PlaceOrderRequest request) async {
    begins++;
    return SandboxPaymentSession(
        attemptKey: 'a',
        reference: 'ref',
        invoiceId: 123,
        checkoutUrl: Uri.parse('https://demo.myfatoorah.com/test'),
        orderTotalEgp: request.total,
        ownerId: owner);
  }

  @override
  Future<SandboxPaymentStatus> check(SandboxPaymentSession session) async {
    checks++;
    if (offline) throw StateError('offline');
    return status;
  }

  @override
  Future<void> forget(SandboxPaymentSession session) async {
    forgotten++;
  }
}

void main() {
  setUp(() async {
    await serviceLocator.reset();
    configureDependencies();
  });
  tearDown(() async {
    await serviceLocator.reset();
  });

  Future<CheckoutCubit> checkout(FakePayments payments,
      {OrdersRepository? orders,
      bool Function(String)? isCurrentAccount}) async {
    final order = await request();
    final bag = serviceLocator<CartRepository>();
    await bag.addItem(order.items.single);
    final repository = CheckoutRepositoryImpl(DemoCheckoutDataSource());
    final cubit = CheckoutCubit(
        GetCart(bag),
        GetCheckoutOptions(repository),
        serviceLocator<GetAppliedPromotion>(),
        serviceLocator<GetDefaultAddress>(),
        PlaceOrder(repository, orders ?? serviceLocator<OrdersRepository>()),
        ClearCart(bag),
        sandboxPayments: payments,
        isCurrentAccount: isCurrentAccount);
    addTearDown(cubit.close);
    await cubit.load();
    cubit.saveAddress(order.address);
    cubit.selectDelivery(order.delivery);
    cubit.selectPayment(order.payment);
    return cubit;
  }

  test('pending, declined and offline results retain bag; paid places once',
      () async {
    final payments = FakePayments();
    final cubit = await checkout(payments);
    final initialCount =
        (await serviceLocator<OrdersRepository>().getOrders()).length;
    await cubit.submitOrder();
    expect(cubit.state, isA<CheckoutPaymentPending>());
    await cubit.submitOrder();
    expect(payments.begins, 1);
    await cubit.checkPayment();
    payments.status = SandboxPaymentStatus.declined;
    await cubit.checkPayment();
    payments.offline = true;
    await cubit.checkPayment();
    expect((cubit.state as CheckoutPaymentPending).message, 'error');
    expect(await serviceLocator<CartRepository>().getItems(), hasLength(1));
    expect(await serviceLocator<OrdersRepository>().getOrders(),
        hasLength(initialCount));
    payments.offline = false;
    payments.status = SandboxPaymentStatus.paid;
    await cubit.checkPayment();
    final receipt = (cubit.state as CheckoutCompleted).receipt;
    expect(receipt.orderId, 'NOVA-TEST-123');
    expect(receipt.sandboxPayment!.invoiceId, 123);
    expect(await serviceLocator<CartRepository>().getItems(), isEmpty);
    final saved =
        await serviceLocator<OrdersRepository>().getOrderById(receipt.orderId);
    expect(saved.sandboxPayment!.invoiceId, 123);
    // A lost save acknowledgement can replay persistence with the same ID.
    await serviceLocator<OrdersRepository>().saveOrder(saved);
    await cubit.checkPayment();
    await cubit.submitOrder();
    expect(await serviceLocator<OrdersRepository>().getOrders(),
        hasLength(initialCount + 1));
  });
  test(
      'paid persistence failure retries saving without starting another payment',
      () async {
    final orders = _FailOnceOrders(serviceLocator<OrdersRepository>());
    final payments = FakePayments()..status = SandboxPaymentStatus.paid;
    final cubit = await checkout(payments, orders: orders);
    await cubit.submitOrder();
    await cubit.checkPayment();
    expect((cubit.state as CheckoutPaymentPending).message, 'saveError');
    expect(await serviceLocator<CartRepository>().getItems(), isNotEmpty);
    await cubit.checkPayment();
    expect(cubit.state, isA<CheckoutCompleted>());
    expect(payments.begins, 1);
    expect(orders.ids, ['NOVA-TEST-123', 'NOVA-TEST-123']);
  });
  test('changing account before verification cannot place or clear an order',
      () async {
    var current = 'alice';
    final payments = FakePayments()
      ..owner = 'alice'
      ..status = SandboxPaymentStatus.paid;
    final cubit =
        await checkout(payments, isCurrentAccount: (uid) => uid == current);
    final initialCount =
        (await serviceLocator<OrdersRepository>().getOrders()).length;
    await cubit.submitOrder();
    current = 'bob';
    await cubit.checkPayment();
    expect(cubit.state, isA<CheckoutPaymentPending>());
    expect(await serviceLocator<CartRepository>().getItems(), isNotEmpty);
    expect(await serviceLocator<OrdersRepository>().getOrders(),
        hasLength(initialCount));
  });
  test('cancelled invoice is discarded before starting a new attempt',
      () async {
    final payments = FakePayments()..status = SandboxPaymentStatus.cancelled;
    final cubit = await checkout(payments);
    await cubit.submitOrder();
    await cubit.checkPayment();
    expect(payments.forgotten, 1);
    cubit.leavePayment();
    await cubit.submitOrder();
    expect(payments.begins, 2);
  });
}

class _FailOnceOrders implements OrdersRepository {
  _FailOnceOrders(this.delegate);
  final OrdersRepository delegate;
  final ids = <String>[];
  @override
  Future<void> saveOrder(Order order) async {
    ids.add(order.id);
    if (ids.length == 1) throw StateError('offline');
    await delegate.saveOrder(order);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
