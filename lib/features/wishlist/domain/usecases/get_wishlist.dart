import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/wishlist/domain/repositories/wishlist_repository.dart';

class GetWishlist {
  const GetWishlist(this._repository);

  final WishlistRepository _repository;

  Future<List<Product>> call() => _repository.getItems();
}
