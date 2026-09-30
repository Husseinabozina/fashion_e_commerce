import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/delivery_option.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/payment_option.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/shipping_address.dart';

class PlaceOrderRequest {
  const PlaceOrderRequest({
    required this.items,
    required this.address,
    required this.delivery,
    required this.payment,
  });

  final List<CartItem> items;
  final ShippingAddress address;
  final DeliveryOption delivery;
  final PaymentOption payment;

  double get subtotal {
    return items.fold<double>(
      0,
      (sum, item) => sum + item.lineTotal,
    );
  }

  double get total => subtotal + delivery.price;
}
