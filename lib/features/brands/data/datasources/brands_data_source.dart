import 'package:fashion_e_commerce/features/brands/domain/entities/brand.dart';

abstract interface class BrandsDataSource {
  Future<Brand> readByName(String name);

  Future<bool> isFollowing(String brandId);

  Future<bool> toggleFollow(String brandId);
}
