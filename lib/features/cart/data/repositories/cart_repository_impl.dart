import 'package:fashion_e_commerce/features/cart/data/datasources/cart_data_source.dart';
import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._dataSource);

  final CartDataSource _dataSource;

  @override
  Future<List<CartItem>> getItems() => _dataSource.read();

  @override
  Future<List<CartItem>> addItem(CartItem item) => _dataSource.add(item);

  @override
  Future<List<CartItem>> updateQuantity(String key, int quantity) {
    return _dataSource.updateQuantity(key, quantity);
  }

  @override
  Future<List<CartItem>> removeItem(String key) => _dataSource.remove(key);
}
