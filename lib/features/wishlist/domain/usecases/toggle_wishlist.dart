import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/wishlist/domain/repositories/wishlist_repository.dart';

class ToggleWishlist {
  const ToggleWishlist(this._repository);

  final WishlistRepository _repository;

  Future<List<Product>> call(Product product) => _repository.toggle(product);
}
