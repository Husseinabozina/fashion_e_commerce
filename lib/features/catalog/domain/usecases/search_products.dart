import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';
import 'package:fashion_e_commerce/features/catalog/domain/repositories/catalog_repository.dart';

class SearchProducts {
  const SearchProducts(this._repository);

  final CatalogRepository _repository;

  Future<List<Product>> call(ProductSearchCriteria criteria) {
    return _repository.searchProducts(criteria);
  }
}
