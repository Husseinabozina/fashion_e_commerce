import 'package:fashion_e_commerce/features/catalog/data/datasources/demo_catalog_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/search_products.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/catalog_browse_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog browse exposes categories and brands', () async {
    final repository = CatalogRepositoryImpl(DemoCatalogDataSource());
    final cubit = CatalogBrowseCubit(SearchProducts(repository));

    await cubit.load();

    final state = cubit.state;
    expect(state, isA<CatalogBrowseLoaded>());

    final loaded = state as CatalogBrowseLoaded;
    expect(loaded.categories, contains('Sneakers'));
    expect(loaded.brands, contains('NIKE'));

    await cubit.close();
  });

  test('search supports an initial category criteria', () async {
    final repository = CatalogRepositoryImpl(DemoCatalogDataSource());
    final products = await repository.searchProducts(
      const ProductSearchCriteria(category: 'Hoodies'),
    );

    expect(products, hasLength(1));
    expect(products.single.category, 'Hoodies');
  });
}
