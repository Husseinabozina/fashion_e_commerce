import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:fashion_e_commerce/features/cart/data/models/cart_item_mapper.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order_status.dart';

abstract final class OrderMapper {
  static Map<String, dynamic> encode(Order order) => {
        'isDemo': true,
        'items': order.items.map(CartItemMapper.snapshot).toList(),
        'total': order.total,
        'createdAt': FieldValue.serverTimestamp(),
        'deliveryEta': order.deliveryEta,
        'shippingAddressLabel': order.shippingAddressLabel,
        'deliveryTitle': order.deliveryTitle,
        'paymentTitle': order.paymentTitle,
        'status': order.status.name,
        'returnRequestId': null,
      };
  static Order decode(String id, Map<String, dynamic> d) => Order(
      id: id,
      items: (d['items'] as List)
          .map((item) => CartItemMapper.fromSnapshot(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
      total: (d['total'] as num).toDouble(),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      deliveryEta: d['deliveryEta'] as String,
      shippingAddressLabel: d['shippingAddressLabel'] as String,
      deliveryTitle: d['deliveryTitle'] as String,
      paymentTitle: d['paymentTitle'] as String,
      status: OrderStatus.values.byName(d['status'] as String));
}
