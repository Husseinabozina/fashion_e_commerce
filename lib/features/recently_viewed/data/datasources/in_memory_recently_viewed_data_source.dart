import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/recently_viewed/data/datasources/recently_viewed_data_source.dart';

class InMemoryRecentlyViewedDataSource implements RecentlyViewedDataSource {
  final List<Product> _items = <Product>[];

  @override
  Future<List<Product>> read() async {
    return List<Product>.unmodifiable(_items);
  }

  @override
  Future<List<Product>> track(Product product) async {
    _items.removeWhere((item) => item.id == product.id);
    _items.insert(0, product);

    if (_items.length > 8) {
      _items.removeRange(8, _items.length);
    }

    return read();
  }
}
