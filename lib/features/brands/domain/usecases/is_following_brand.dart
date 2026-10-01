import 'package:fashion_e_commerce/features/brands/domain/repositories/brands_repository.dart';

class IsFollowingBrand {
  const IsFollowingBrand(this._repository);

  final BrandsRepository _repository;

  Future<bool> call(String brandId) => _repository.isFollowing(brandId);
}
