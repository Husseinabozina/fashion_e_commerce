import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/delivery_option.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/payment_option.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/shipping_address.dart';
import 'package:fashion_e_commerce/features/promotions/domain/entities/promotion.dart';
import 'sandbox_payment.dart';

class PlaceOrderRequest {
  const PlaceOrderRequest({
    required this.items,
    required this.address,
    required this.delivery,
    required this.payment,
    this.promotion,
    this.idempotencyKey,
    this.sandboxPayment,
  });

  final List<CartItem> items;
  final ShippingAddress address;
  final DeliveryOption delivery;
  final PaymentOption payment;
  final Promotion? promotion;
  final String? idempotencyKey;
  final SandboxPaymentReceipt? sandboxPayment;

  double get subtotal {
    return items.fold<double>(
      0,
      (sum, item) => sum + item.lineTotal,
    );
  }

  double get discount => promotion?.discountFor(subtotal) ?? 0;

  double get total => subtotal - discount + delivery.price;
}
