import 'package:fashion_e_commerce/features/orders/domain/entities/order.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/return_request.dart';

abstract interface class OrdersRepository {
  Future<void> saveOrder(Order order);

  Future<List<Order>> getOrders();

  Future<Order> getOrderById(String orderId);

  Future<ReturnRequest> submitReturnRequest(ReturnRequest request);
}
