import 'package:fashion_e_commerce/features/cart/data/datasources/cart_data_source.dart';
import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';

class InMemoryCartDataSource implements CartDataSource {
  final List<CartItem> _items = <CartItem>[];

  @override
  Future<List<CartItem>> read() async {
    return List<CartItem>.unmodifiable(_items);
  }

  @override
  Future<List<CartItem>> add(CartItem item) async {
    final index = _items.indexWhere((candidate) => candidate.key == item.key);

    if (index == -1) {
      _items.add(item);
    } else {
      final current = _items[index];
      _items[index] = current.copyWith(
        quantity: current.quantity + item.quantity,
      );
    }

    return read();
  }

  @override
  Future<List<CartItem>> updateQuantity(String key, int quantity) async {
    final index = _items.indexWhere((candidate) => candidate.key == key);
    if (index == -1) return read();

    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }

    return read();
  }

  @override
  Future<List<CartItem>> remove(String key) async {
    _items.removeWhere((item) => item.key == key);
    return read();
  }

  @override
  Future<void> clear() async {
    _items.clear();
  }
}
