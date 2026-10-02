import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/recently_viewed/data/datasources/in_memory_recently_viewed_data_source.dart';
import 'package:fashion_e_commerce/features/recently_viewed/data/repositories/recently_viewed_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const first = Product(
    id: 'one',
    brand: 'NOVA',
    name: 'One',
    category: 'Sneakers',
    price: 100,
    imageUrl: '',
    colors: <String>['Black'],
    sizes: <String>['42'],
    fit: 'Regular',
    description: 'One',
  );

  const second = Product(
    id: 'two',
    brand: 'NOVA',
    name: 'Two',
    category: 'Jackets',
    price: 200,
    imageUrl: '',
    colors: <String>['Black'],
    sizes: <String>['M'],
    fit: 'Regular',
    description: 'Two',
  );

  test('recently viewed deduplicates and keeps newest first', () async {
    final repository = RecentlyViewedRepositoryImpl(
      InMemoryRecentlyViewedDataSource(),
    );

    await repository.track(first);
    await repository.track(second);
    final items = await repository.track(first);

    expect(items, hasLength(2));
    expect(items.first.id, first.id);
    expect(items.last.id, second.id);
  });
}
