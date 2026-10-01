import 'package:fashion_e_commerce/features/brands/domain/entities/brand.dart';
import 'package:fashion_e_commerce/features/brands/domain/repositories/brands_repository.dart';

class GetBrand {
  const GetBrand(this._repository);

  final BrandsRepository _repository;

  Future<Brand> call(String name) => _repository.getBrandByName(name);
}
