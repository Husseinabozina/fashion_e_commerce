import 'package:fashion_e_commerce/features/brands/domain/repositories/brands_repository.dart';

class ToggleBrandFollow {
  const ToggleBrandFollow(this._repository);

  final BrandsRepository _repository;

  Future<bool> call(String brandId) => _repository.toggleFollow(brandId);
}
