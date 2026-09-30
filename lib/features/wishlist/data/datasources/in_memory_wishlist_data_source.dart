import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/wishlist/data/datasources/wishlist_data_source.dart';

class InMemoryWishlistDataSource implements WishlistDataSource {
  final List<Product> _items = <Product>[];

  @override
  Future<List<Product>> read() async {
    return List<Product>.unmodifiable(_items);
  }

  @override
  Future<List<Product>> toggle(Product product) async {
    final index = _items.indexWhere((item) => item.id == product.id);

    if (index == -1) {
      _items.add(product);
    } else {
      _items.removeAt(index);
    }

    return read();
  }
}
