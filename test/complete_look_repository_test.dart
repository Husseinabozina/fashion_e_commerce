import 'package:fashion_e_commerce/features/catalog/data/datasources/demo_catalog_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('complete look excludes anchor and favors complementary categories',
      () async {
    final repository = CatalogRepositoryImpl(DemoCatalogDataSource());

    final look = await repository.getCompleteLook('nb-9060');

    expect(look, isNotEmpty);
    expect(look.every((product) => product.id != 'nb-9060'), isTrue);
    expect(
      look.any((product) => product.category != 'Sneakers'),
      isTrue,
    );
  });
}
