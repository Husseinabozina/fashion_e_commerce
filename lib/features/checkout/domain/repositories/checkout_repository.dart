import 'package:fashion_e_commerce/features/checkout/domain/entities/checkout_options.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/order_receipt.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/place_order_request.dart';

abstract interface class CheckoutRepository {
  Future<CheckoutOptions> getOptions();

  Future<OrderReceipt> placeOrder(PlaceOrderRequest request);
}
