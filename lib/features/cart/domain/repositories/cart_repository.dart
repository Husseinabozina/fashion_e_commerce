import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';

abstract interface class CartRepository {
  Future<List<CartItem>> getItems();

  Future<List<CartItem>> addItem(CartItem item);

  Future<List<CartItem>> updateQuantity(String key, int quantity);

  Future<List<CartItem>> removeItem(String key);
}
