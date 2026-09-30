import 'package:fashion_e_commerce/features/cart/domain/repositories/cart_repository.dart';

class ClearCart {
  const ClearCart(this._repository);

  final CartRepository _repository;

  Future<void> call() => _repository.clear();
}
