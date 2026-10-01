import 'package:fashion_e_commerce/features/brands/domain/entities/brand.dart';

abstract interface class BrandsRepository {
  Future<Brand> getBrandByName(String name);

  Future<bool> isFollowing(String brandId);

  Future<bool> toggleFollow(String brandId);
}
