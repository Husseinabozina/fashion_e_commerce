import 'package:fashion_e_commerce/features/catalog/data/datasources/catalog_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/home_catalog.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl(this._dataSource);

  final CatalogDataSource _dataSource;

  @override
  Future<HomeCatalog> getHomeCatalog() async {
    final products = await _dataSource.fetchProducts();
    final categories = await _dataSource.fetchCategories();

    if (products.isEmpty) {
      throw StateError('Catalog cannot build a home feed without products.');
    }

    return HomeCatalog(
      heroProduct: products.first,
      newArrivals: products,
      categories: categories,
    );
  }

  @override
  Future<Product> getProductById(String id) async {
    final products = await _dataSource.fetchProducts();

    return products.firstWhere(
      (product) => product.id == id,
      orElse: () => throw StateError('Product not found: $id'),
    );
  }
}
