import 'package:fashion_e_commerce/features/catalog/domain/entities/home_catalog.dart';
import 'package:fashion_e_commerce/features/catalog/domain/repositories/catalog_repository.dart';

class GetHomeCatalog {
  const GetHomeCatalog(this._repository);

  final CatalogRepository _repository;

  Future<HomeCatalog> call() => _repository.getHomeCatalog();
}
