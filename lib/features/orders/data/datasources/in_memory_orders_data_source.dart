import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/orders/data/datasources/orders_data_source.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order_status.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/return_request.dart';

class InMemoryOrdersDataSource implements OrdersDataSource {
  InMemoryOrdersDataSource()
      : _orders = <Order>[
          Order(
            id: 'NOVA-025884',
            items: const <CartItem>[
              CartItem(
                product: Product(
                  id: 'nb-9060',
                  brand: 'NEW BALANCE',
                  name: '9060',
                  category: 'Sneakers',
                  price: 3499,
                  imageUrl:
                      'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=900&q=80',
                  colors: <String>['Black', 'Grey', 'Sand'],
                  sizes: <String>['40', '41', '42', '43', '44'],
                  fit: 'Regular fit',
                  description: 'A layered street runner.',
                ),
                color: 'Black',
                size: '42',
              ),
            ],
            total: 3499,
            createdAt: DateTime(2026, 9, 24, 14, 20),
            deliveryEta: 'Delivered 27 Sep',
            shippingAddressLabel: 'Main Street, City Centre, Damietta',
            deliveryTitle: 'Standard Delivery',
            paymentTitle: 'Card',
            status: OrderStatus.delivered,
          ),
        ];

  final List<Order> _orders;
  final List<ReturnRequest> _returnRequests = <ReturnRequest>[];

  @override
  Future<void> save(Order order) async {
    _orders.insert(0, order);
  }

  @override
  Future<List<Order>> readAll() async {
    return List<Order>.unmodifiable(_orders);
  }

  @override
  Future<Order> readById(String orderId) async {
    return _orders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => throw StateError('Order not found: $orderId'),
    );
  }

  @override
  Future<ReturnRequest> submitReturn(ReturnRequest request) async {
    _returnRequests.add(request);

    final index = _orders.indexWhere((order) => order.id == request.orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(
        status: OrderStatus.returnRequested,
      );
    }

    return request;
  }
}
