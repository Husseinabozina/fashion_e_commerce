import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order_status.dart';

class Order {
  const Order({
    required this.id,
    this.ownerId,
    required this.items,
    required this.total,
    required this.createdAt,
    required this.deliveryEta,
    required this.shippingAddressLabel,
    required this.deliveryTitle,
    required this.paymentTitle,
    required this.status,
  });

  final String id;
  final String? ownerId;
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;
  final String deliveryEta;
  final String shippingAddressLabel;
  final String deliveryTitle;
  final String paymentTitle;
  final OrderStatus status;

  Order copyWith({
    OrderStatus? status,
  }) {
    return Order(
      id: id,
      ownerId: ownerId,
      items: items,
      total: total,
      createdAt: createdAt,
      deliveryEta: deliveryEta,
      shippingAddressLabel: shippingAddressLabel,
      deliveryTitle: deliveryTitle,
      paymentTitle: paymentTitle,
      status: status ?? this.status,
    );
  }
}
