import 'package:fashion_e_commerce/features/checkout/domain/entities/order_receipt.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/place_order_request.dart';
import 'package:fashion_e_commerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order_status.dart';
import 'package:fashion_e_commerce/features/orders/domain/repositories/orders_repository.dart';

class PlaceOrder {
  const PlaceOrder(
    this._checkoutRepository,
    this._ordersRepository,
  );

  final CheckoutRepository _checkoutRepository;
  final OrdersRepository _ordersRepository;

  Future<OrderReceipt> call(PlaceOrderRequest request) async {
    final receipt = await _checkoutRepository.placeOrder(request);

    await _ordersRepository.saveOrder(
      Order(
        id: receipt.orderId,
        items: request.items,
        total: receipt.total,
        createdAt: DateTime.now(),
        deliveryEta: receipt.deliveryEta,
        shippingAddressLabel:
            '${request.address.fullName}\n${request.address.compactLabel}\n${request.address.phone}',
        deliveryTitle: request.delivery.title,
        paymentTitle: request.payment.title,
        status: OrderStatus.placed,
      ),
    );

    return receipt;
  }
}
