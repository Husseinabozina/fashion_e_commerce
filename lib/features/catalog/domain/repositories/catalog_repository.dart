import 'package:fashion_e_commerce/features/catalog/domain/entities/home_catalog.dart';

abstract interface class CatalogRepository {
  Future<HomeCatalog> getHomeCatalog();
}
