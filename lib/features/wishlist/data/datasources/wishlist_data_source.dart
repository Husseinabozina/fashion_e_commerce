import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';

abstract interface class WishlistDataSource {
  Future<List<Product>> read();

  Future<List<Product>> toggle(Product product);
}
