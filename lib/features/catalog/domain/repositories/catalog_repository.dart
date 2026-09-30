import 'package:fashion_e_commerce/features/catalog/domain/entities/home_catalog.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';

abstract interface class CatalogRepository {
  Future<HomeCatalog> getHomeCatalog();

  Future<Product> getProductById(String id);
}
