import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/recently_viewed/domain/repositories/recently_viewed_repository.dart';

class TrackRecentlyViewed {
  const TrackRecentlyViewed(this._repository);

  final RecentlyViewedRepository _repository;

  Future<List<Product>> call(Product product) {
    return _repository.track(product);
  }
}
