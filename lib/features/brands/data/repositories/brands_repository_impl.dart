import 'package:fashion_e_commerce/features/brands/data/datasources/brands_data_source.dart';
import 'package:fashion_e_commerce/features/brands/domain/entities/brand.dart';
import 'package:fashion_e_commerce/features/brands/domain/repositories/brands_repository.dart';

class BrandsRepositoryImpl implements BrandsRepository {
  const BrandsRepositoryImpl(this._dataSource);

  final BrandsDataSource _dataSource;

  @override
  Future<Brand> getBrandByName(String name) {
    return _dataSource.readByName(name);
  }

  @override
  Future<List<Brand>> getFollowingBrands() {
    return _dataSource.readFollowing();
  }

  @override
  Future<bool> isFollowing(String brandId) {
    return _dataSource.isFollowing(brandId);
  }

  @override
  Future<bool> toggleFollow(String brandId) {
    return _dataSource.toggleFollow(brandId);
  }
}
