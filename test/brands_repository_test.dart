import 'package:fashion_e_commerce/features/brands/data/datasources/in_memory_brands_data_source.dart';
import 'package:fashion_e_commerce/features/brands/data/repositories/brands_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('brand metadata loads and follow state toggles persist', () async {
    final repository = BrandsRepositoryImpl(
      InMemoryBrandsDataSource(),
    );

    final brand = await repository.getBrandByName('nike');
    expect(brand.name, 'NIKE');
    expect(await repository.isFollowing(brand.id), isFalse);

    expect(await repository.toggleFollow(brand.id), isTrue);
    expect(await repository.isFollowing(brand.id), isTrue);

    expect(await repository.toggleFollow(brand.id), isFalse);
    expect(await repository.isFollowing(brand.id), isFalse);
  });
}
