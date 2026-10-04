import 'package:fashion_e_commerce/features/catalog/data/datasources/catalog_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/home_catalog.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';
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

  @override
  Future<List<Product>> getCompleteLook(String productId) async {
    final products = await _dataSource.fetchProducts();
    final anchor = products.firstWhere(
      (product) => product.id == productId,
      orElse: () => throw StateError('Product not found: $productId'),
    );

    final differentCategory = products
        .where(
          (product) =>
              product.id != anchor.id &&
              product.category != anchor.category,
        )
        .take(3)
        .toList();

    if (differentCategory.length >= 3) {
      return differentCategory;
    }

    final usedIds = <String>{
      anchor.id,
      ...differentCategory.map((product) => product.id),
    };

    final fill = products
        .where((product) => !usedIds.contains(product.id))
        .take(3 - differentCategory.length);

    return <Product>[
      ...differentCategory,
      ...fill,
    ];
  }

  @override
  Future<List<Product>> searchProducts(ProductSearchCriteria criteria) async {
    final products = await _dataSource.fetchProducts();
    final normalizedQuery = criteria.query.trim().toLowerCase();

    final filtered = products.where((product) {
      final matchesQuery = normalizedQuery.isEmpty ||
          product.name.toLowerCase().contains(normalizedQuery) ||
          product.brand.toLowerCase().contains(normalizedQuery) ||
          product.category.toLowerCase().contains(normalizedQuery);

      final matchesCategory = criteria.category == null ||
          product.category == criteria.category;

      final matchesBrand =
          criteria.brand == null || product.brand == criteria.brand;

      return matchesQuery && matchesCategory && matchesBrand;
    }).toList();

    switch (criteria.sort) {
      case ProductSort.recommended:
        break;
      case ProductSort.newest:
        filtered.sort((a, b) {
          if (a.isNew == b.isNew) return 0;
          return a.isNew ? -1 : 1;
        });
      case ProductSort.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    return filtered;
  }
}
