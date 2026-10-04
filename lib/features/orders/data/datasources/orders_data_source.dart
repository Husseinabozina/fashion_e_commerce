import 'package:fashion_e_commerce/features/orders/domain/entities/order.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/return_request.dart';

abstract interface class OrdersDataSource {
  Future<void> save(Order order);

  Future<List<Order>> readAll();

  Future<Order> readById(String orderId);

  Future<ReturnRequest> submitReturn(ReturnRequest request);
}
