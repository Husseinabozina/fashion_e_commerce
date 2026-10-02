import 'package:fashion_e_commerce/features/orders/data/datasources/in_memory_orders_data_source.dart';
import 'package:fashion_e_commerce/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order_status.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/return_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('orders expose demo history and return request updates status', () async {
    final repository =
        OrdersRepositoryImpl(InMemoryOrdersDataSource());

    final orders = await repository.getOrders();
    expect(orders, isNotEmpty);
    expect(orders.first.status, OrderStatus.delivered);

    final order = orders.first;
    final item = order.items.first;
    final request = ReturnRequest(
      id: 'RET-1',
      orderId: order.id,
      itemKey: item.key,
      type: ReturnRequestType.exchangeSize,
      reason: 'Wrong size',
      requestedSize: '43',
      status: ReturnRequestStatus.submitted,
    );

    final submitted = await repository.submitReturnRequest(request);
    expect(submitted.requestedSize, '43');

    final updated = await repository.getOrderById(order.id);
    expect(updated.status, OrderStatus.returnRequested);
  });
}
