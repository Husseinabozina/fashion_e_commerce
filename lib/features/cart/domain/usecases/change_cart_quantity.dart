import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/cart/domain/repositories/cart_repository.dart';

class ChangeCartQuantity {
  const ChangeCartQuantity(this._repository);

  final CartRepository _repository;

  Future<List<CartItem>> call(String key, int quantity) {
    return _repository.updateQuantity(key, quantity);
  }
}
