import 'dart:async';

import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/features/addresses/domain/usecases/get_default_address.dart';
import 'package:fashion_e_commerce/features/cart/data/datasources/in_memory_cart_data_source.dart';
import 'package:fashion_e_commerce/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/clear_cart.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/get_cart.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/checkout/data/datasources/demo_checkout_data_source.dart';
import 'package:fashion_e_commerce/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/order_receipt.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/place_order_request.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/shipping_address.dart';
import 'package:fashion_e_commerce/features/checkout/domain/usecases/get_checkout_options.dart';
import 'package:fashion_e_commerce/features/checkout/domain/usecases/place_order.dart';
import 'package:fashion_e_commerce/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:fashion_e_commerce/features/orders/domain/repositories/orders_repository.dart';
import 'package:fashion_e_commerce/features/promotions/domain/usecases/get_applied_promotion.dart';
import 'package:flutter_test/flutter_test.dart';

const _item = CartItem(
  product: Product(
      id: 'test',
      brand: 'NOVA',
      name: 'Runner',
      category: 'Sneakers',
      price: 1000,
      imageUrl: '',
      colors: ['Black'],
      sizes: ['42'],
      fit: 'Regular',
      description: 'Test'),
  color: 'Black',
  size: '42',
  quantity: 2,
);
const _address = ShippingAddress(
    fullName: 'Test User',
    phone: '01000000000',
    city: 'Cairo',
    area: 'Centre',
    street: 'Main Street',
    building: '12');

void main() {
  setUp(() async {
    await serviceLocator.reset();
    configureDependencies();
  });
  tearDown(() async {
    await serviceLocator.reset();
  });

  Future<CheckoutCubit> ready(_ControlledCheckout checkout,
      {CartRepository? cart,
      bool Function(String)? isCurrentAccount,
      String Function()? submissionIdFactory}) async {
    final bag = cart ?? serviceLocator<CartRepository>();
    await bag.addItem(_item);
    final cubit = CheckoutCubit(
        GetCart(bag),
        GetCheckoutOptions(checkout),
        serviceLocator<GetAppliedPromotion>(),
        serviceLocator<GetDefaultAddress>(),
        PlaceOrder(checkout, serviceLocator<OrdersRepository>()),
        ClearCart(bag),
        isCurrentAccount: isCurrentAccount,
        submissionIdFactory: submissionIdFactory);
    addTearDown(cubit.close);
    await cubit.load();
    cubit.saveAddress(_address);
    final options = (cubit.state as CheckoutReady).options;
    cubit.selectDelivery(options.deliveryOptions.last);
    cubit.selectPayment(options.paymentOptions[1]);
    return cubit;
  }

  test('completed order does not clear the bag after an account transition',
      () async {
    final checkout = _ControlledCheckout()
      ..gate = Completer<void>()
      ..ownerId = 'alice';
    var account = 'alice';
    final cubit =
        await ready(checkout, isCurrentAccount: (uid) => uid == account);
    final pending = cubit.submitOrder();
    account = 'bob';
    checkout.gate!.complete();
    await pending;
    expect((cubit.state as CheckoutCompleted).cartCleared, isFalse);
    expect(await serviceLocator<CartRepository>().getItems(), isNotEmpty);
  });

  test('placement retry retains the same submission key', () async {
    final checkout = _ControlledCheckout()..failOnce = true;
    final cubit =
        await ready(checkout, submissionIdFactory: () => 'one-attempt');
    await cubit.submitOrder();
    await cubit.submitOrder();
    expect(checkout.keys, ['one-attempt', 'one-attempt']);
  });

  test(
      'rapid confirmation places one order and freezes navigation during submission',
      () async {
    final checkout = _ControlledCheckout()..gate = Completer<void>();
    final cubit = await ready(checkout);
    final submit = cubit.submitOrder();
    await cubit.submitOrder();
    cubit.goBack();
    cubit.saveAddress(_address);
    final pending = cubit.state as CheckoutReady;
    expect(pending.isSubmitting, isTrue);
    expect(pending.step, CheckoutStep.review);
    expect(checkout.calls, 1);
    checkout.gate!.complete();
    await submit;
    final completed = cubit.state as CheckoutCompleted;
    expect(completed.receipt.total, 2090);
    expect(await serviceLocator<CartRepository>().getItems(), isEmpty);
    final order = await serviceLocator<OrdersRepository>()
        .getOrderById(completed.receipt.orderId);
    expect(order.shippingAddressLabel,
        'Test User\n12, Main Street, Centre, Cairo\n01000000000');
  });

  test(
      'failed placement retains review selections and allows a successful retry',
      () async {
    final checkout = _ControlledCheckout()..failOnce = true;
    final cubit = await ready(checkout);
    final review = cubit.state as CheckoutReady;
    await cubit.submitOrder();
    final failed = cubit.state as CheckoutReady;
    expect(failed.step, CheckoutStep.review);
    expect(failed.hasSubmissionError, isTrue);
    expect(failed.isSubmitting, isFalse);
    expect(failed.address, same(review.address));
    expect(failed.delivery, same(review.delivery));
    expect(failed.payment, same(review.payment));
    expect(await serviceLocator<CartRepository>().getItems(), isNotEmpty);
    await cubit.submitOrder();
    expect(cubit.state, isA<CheckoutCompleted>());
    expect(checkout.calls, 2);
  });

  test(
      'cart cleanup failure keeps confirmation and cannot resubmit a placed order',
      () async {
    final checkout = _ControlledCheckout();
    final cubit = await ready(checkout, cart: _FailingCleanupCart());
    await cubit.submitOrder();
    expect((cubit.state as CheckoutCompleted).cartCleared, isFalse);
    await cubit.submitOrder();
    expect(checkout.calls, 1);
    expect(await serviceLocator<OrdersRepository>().getOrderById('NOVA-026001'),
        isNotNull);
  });

  test(
      'two purchases have distinct retrievable IDs and retain their own totals',
      () async {
    final checkout = _ControlledCheckout();
    final first = await ready(checkout);
    await first.submitOrder();
    final second = await ready(checkout);
    final options = (second.state as CheckoutReady).options;
    second.goBack();
    second.goBack();
    second.selectDelivery(options.deliveryOptions.first);
    second.selectPayment(options.paymentOptions[1]);
    await second.submitOrder();
    final a = (first.state as CheckoutCompleted).receipt;
    final b = (second.state as CheckoutCompleted).receipt;
    expect(a.orderId, isNot(b.orderId));
    final orders = serviceLocator<OrdersRepository>();
    expect((await orders.getOrderById(a.orderId)).total, 2090);
    expect((await orders.getOrderById(b.orderId)).total, 2000);
  });

  test(
      'finishing a request after the screen closes does not emit to a closed cubit',
      () async {
    final checkout = _ControlledCheckout()..gate = Completer<void>();
    final cubit = await ready(checkout);
    final submit = cubit.submitOrder();
    await cubit.close();
    checkout.gate!.complete();
    await expectLater(submit, completes);
    expect(await serviceLocator<CartRepository>().getItems(), isEmpty);
  });
}

class _ControlledCheckout extends CheckoutRepositoryImpl {
  _ControlledCheckout() : super(DemoCheckoutDataSource());
  int calls = 0;
  String? ownerId;
  final keys = <String?>[];
  bool failOnce = false;
  Completer<void>? gate;
  @override
  Future<OrderReceipt> placeOrder(PlaceOrderRequest request) async {
    calls++;
    keys.add(request.idempotencyKey);
    if (gate != null) await gate!.future;
    if (failOnce) {
      failOnce = false;
      throw StateError('offline');
    }
    final receipt = await super.placeOrder(request);
    return OrderReceipt(
        orderId: receipt.orderId,
        ownerId: ownerId,
        total: receipt.total,
        deliveryEta: receipt.deliveryEta);
  }
}

class _FailingCleanupCart extends CartRepositoryImpl {
  _FailingCleanupCart() : super(InMemoryCartDataSource());
  @override
  Future<void> clear() async => throw StateError('cleanup failed');
}
