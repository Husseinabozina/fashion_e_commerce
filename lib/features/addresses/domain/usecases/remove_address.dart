import 'package:fashion_e_commerce/features/addresses/domain/entities/saved_address.dart';
import 'package:fashion_e_commerce/features/addresses/domain/repositories/addresses_repository.dart';

class RemoveAddress {
  const RemoveAddress(this._repository);

  final AddressesRepository _repository;

  Future<List<SavedAddress>> call(String id) {
    return _repository.removeAddress(id);
  }
}
