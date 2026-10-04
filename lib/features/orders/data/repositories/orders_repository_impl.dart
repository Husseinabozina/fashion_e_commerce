import 'package:fashion_e_commerce/features/orders/data/datasources/orders_data_source.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/return_request.dart';
import 'package:fashion_e_commerce/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this._dataSource);

  final OrdersDataSource _dataSource;

  @override
  Future<void> saveOrder(Order order) => _dataSource.save(order);

  @override
  Future<List<Order>> getOrders() => _dataSource.readAll();

  @override
  Future<Order> getOrderById(String orderId) {
    return _dataSource.readById(orderId);
  }

  @override
  Future<ReturnRequest> submitReturnRequest(ReturnRequest request) {
    return _dataSource.submitReturn(request);
  }
}
