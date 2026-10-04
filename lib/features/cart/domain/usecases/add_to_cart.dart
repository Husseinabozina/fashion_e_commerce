import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/cart/domain/repositories/cart_repository.dart';

class AddToCart {
  const AddToCart(this._repository);

  final CartRepository _repository;

  Future<List<CartItem>> call(CartItem item) => _repository.addItem(item);
}
