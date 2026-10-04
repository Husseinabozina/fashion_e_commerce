import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/wishlist/data/datasources/wishlist_data_source.dart';
import 'package:fashion_e_commerce/features/wishlist/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  const WishlistRepositoryImpl(this._dataSource);

  final WishlistDataSource _dataSource;

  @override
  Future<List<Product>> getItems() => _dataSource.read();

  @override
  Future<List<Product>> toggle(Product product) => _dataSource.toggle(product);
}
