import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';

abstract interface class RecentlyViewedRepository {
  Future<List<Product>> getItems();

  Future<List<Product>> track(Product product);
}
