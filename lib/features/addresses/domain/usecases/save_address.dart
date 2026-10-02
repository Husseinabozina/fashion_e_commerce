import 'package:fashion_e_commerce/features/addresses/domain/entities/saved_address.dart';
import 'package:fashion_e_commerce/features/addresses/domain/repositories/addresses_repository.dart';

class SaveAddress {
  const SaveAddress(this._repository);

  final AddressesRepository _repository;

  Future<List<SavedAddress>> call(SavedAddress address) {
    return _repository.saveAddress(address);
  }
}
