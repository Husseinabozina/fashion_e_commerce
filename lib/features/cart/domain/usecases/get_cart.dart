import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/cart/domain/repositories/cart_repository.dart';

class GetCart {
  const GetCart(this._repository);

  final CartRepository _repository;

  Future<List<CartItem>> call() => _repository.getItems();
}
