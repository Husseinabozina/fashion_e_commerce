import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/recently_viewed/data/datasources/recently_viewed_data_source.dart';
import 'package:fashion_e_commerce/features/recently_viewed/domain/repositories/recently_viewed_repository.dart';

class RecentlyViewedRepositoryImpl implements RecentlyViewedRepository {
  const RecentlyViewedRepositoryImpl(this._dataSource);

  final RecentlyViewedDataSource _dataSource;

  @override
  Future<List<Product>> getItems() => _dataSource.read();

  @override
  Future<List<Product>> track(Product product) => _dataSource.track(product);
}
