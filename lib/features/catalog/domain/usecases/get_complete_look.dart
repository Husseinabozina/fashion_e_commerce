import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/domain/repositories/catalog_repository.dart';

class GetCompleteLook {
  const GetCompleteLook(this._repository);

  final CatalogRepository _repository;

  Future<List<Product>> call(String productId) {
    return _repository.getCompleteLook(productId);
  }
}
