import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';

abstract interface class CartDataSource {
  Future<List<CartItem>> read();

  Future<List<CartItem>> add(CartItem item);

  Future<List<CartItem>> updateQuantity(String key, int quantity);

  Future<List<CartItem>> remove(String key);

  Future<void> clear();
}
