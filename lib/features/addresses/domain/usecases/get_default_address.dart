import 'package:fashion_e_commerce/features/addresses/domain/entities/saved_address.dart';
import 'package:fashion_e_commerce/features/addresses/domain/repositories/addresses_repository.dart';

class GetDefaultAddress {
  const GetDefaultAddress(this._repository);

  final AddressesRepository _repository;

  Future<SavedAddress?> call() => _repository.getDefaultAddress();
}
