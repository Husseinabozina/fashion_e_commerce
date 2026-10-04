import 'package:fashion_e_commerce/features/brands/domain/entities/brand.dart';
import 'package:fashion_e_commerce/features/brands/domain/repositories/brands_repository.dart';

class GetFollowingBrands {
  const GetFollowingBrands(this._repository);

  final BrandsRepository _repository;

  Future<List<Brand>> call() => _repository.getFollowingBrands();
}
