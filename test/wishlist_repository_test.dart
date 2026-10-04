import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/wishlist/data/datasources/in_memory_wishlist_data_source.dart';
import 'package:fashion_e_commerce/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const product = Product(
    id: 'wish-1',
    brand: 'NOVA',
    name: 'Saved Runner',
    category: 'Sneakers',
    price: 1500,
    imageUrl: '',
    colors: <String>['Black'],
    sizes: <String>['42'],
    fit: 'Regular',
    description: 'Wishlist test product',
  );

  test('wishlist toggles a product on and off', () async {
    final repository =
        WishlistRepositoryImpl(InMemoryWishlistDataSource());

    final added = await repository.toggle(product);
    expect(added, hasLength(1));
    expect(added.single.id, product.id);

    final removed = await repository.toggle(product);
    expect(removed, isEmpty);
  });
}
