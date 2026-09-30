import 'package:fashion_e_commerce/features/catalog/domain/entities/home_catalog.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';

abstract interface class CatalogRepository {
  Future<HomeCatalog> getHomeCatalog();

  Future<Product> getProductById(String id);

  Future<List<Product>> searchProducts(ProductSearchCriteria criteria);
}
