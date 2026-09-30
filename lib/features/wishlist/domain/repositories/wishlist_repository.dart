import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';

abstract interface class WishlistRepository {
  Future<List<Product>> getItems();

  Future<List<Product>> toggle(Product product);
}
