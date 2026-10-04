import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';

abstract interface class RecentlyViewedDataSource {
  Future<List<Product>> read();

  Future<List<Product>> track(Product product);
}
