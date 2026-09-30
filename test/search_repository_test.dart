import 'package:fashion_e_commerce/features/catalog/data/datasources/demo_catalog_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repository = CatalogRepositoryImpl(DemoCatalogDataSource());

  test('search filters by query and category', () async {
    final nike = await repository.searchProducts(
      const ProductSearchCriteria(query: 'nike'),
    );

    expect(nike, hasLength(1));
    expect(nike.single.brand, 'NIKE');

    final hoodies = await repository.searchProducts(
      const ProductSearchCriteria(category: 'Hoodies'),
    );

    expect(hoodies, hasLength(1));
    expect(hoodies.single.category, 'Hoodies');
  });

  test('search sorts prices low to high', () async {
    final products = await repository.searchProducts(
      const ProductSearchCriteria(
        sort: ProductSort.priceLowToHigh,
      ),
    );

    for (var i = 1; i < products.length; i++) {
      expect(products[i - 1].price <= products[i].price, isTrue);
    }
  });
}
