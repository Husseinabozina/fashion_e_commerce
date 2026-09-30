import 'package:fashion_e_commerce/features/cart/data/datasources/in_memory_cart_data_source.dart';
import 'package:fashion_e_commerce/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const product = Product(
    id: 'shoe-1',
    brand: 'NOVA',
    name: 'Runner',
    price: 1000,
    imageUrl: '',
    colors: <String>['Black'],
    sizes: <String>['42'],
    fit: 'Regular',
    description: 'Test product',
  );

  test('cart merges the same variant and updates quantity', () async {
    final repository = CartRepositoryImpl(InMemoryCartDataSource());
    const item = CartItem(
      product: product,
      color: 'Black',
      size: '42',
    );

    await repository.addItem(item);
    final afterSecondAdd = await repository.addItem(item);

    expect(afterSecondAdd, hasLength(1));
    expect(afterSecondAdd.single.quantity, 2);

    final updated = await repository.updateQuantity(item.key, 3);
    expect(updated.single.quantity, 3);

    final removed = await repository.removeItem(item.key);
    expect(removed, isEmpty);
  });
}
