import 'package:fashion_e_commerce/features/orders/domain/entities/order.dart';
import 'package:fashion_e_commerce/features/orders/domain/repositories/orders_repository.dart';

class GetOrderDetails {
  const GetOrderDetails(this._repository);

  final OrdersRepository _repository;

  Future<Order> call(String orderId) => _repository.getOrderById(orderId);
}
