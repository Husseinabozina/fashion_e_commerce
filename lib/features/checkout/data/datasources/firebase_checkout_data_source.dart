import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/checkout_options.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/order_receipt.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/place_order_request.dart';
import 'checkout_data_source.dart';
import 'demo_checkout_data_source.dart';

/// Persists demo orders through PlaceOrder/OrdersRepository; never charges a card.
class FirebaseCheckoutDataSource implements CheckoutDataSource {
  FirebaseCheckoutDataSource(this.store);
  final FirebaseAccountStore store;
  @override
  Future<CheckoutOptions> fetchOptions() =>
      DemoCheckoutDataSource().fetchOptions();
  @override
  Future<OrderReceipt> submitOrder(PlaceOrderRequest request) async {
    final owner = store.uid;
    final id =
        'NOVA-${request.idempotencyKey ?? store.collection('demoOrders').doc().id}';
    final existing = await store.collection('demoOrders').doc(id).get();
    if (existing.exists)
      return OrderReceipt(
          orderId: id,
          ownerId: owner,
          total: (existing.data()!['total'] as num).toDouble(),
          deliveryEta: existing.data()!['deliveryEta'] as String);
    if (request.items.isEmpty || request.items.length > 20)
      throw StateError('Bag must contain 1–20 items.');
    return OrderReceipt(
        orderId: id,
        ownerId: owner,
        total: request.total,
        deliveryEta: request.delivery.eta);
  }
}
