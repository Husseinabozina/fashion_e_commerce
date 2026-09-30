import 'package:fashion_e_commerce/features/checkout/domain/entities/order_receipt.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/place_order_request.dart';
import 'package:fashion_e_commerce/features/checkout/domain/repositories/checkout_repository.dart';

class PlaceOrder {
  const PlaceOrder(this._repository);

  final CheckoutRepository _repository;

  Future<OrderReceipt> call(PlaceOrderRequest request) {
    return _repository.placeOrder(request);
  }
}
