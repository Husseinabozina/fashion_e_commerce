import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/domain/repositories/catalog_repository.dart';

class GetProductDetails {
  const GetProductDetails(this._repository);

  final CatalogRepository _repository;

  Future<Product> call(String id) => _repository.getProductById(id);
}
