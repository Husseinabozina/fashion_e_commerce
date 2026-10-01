import 'package:fashion_e_commerce/features/addresses/domain/entities/saved_address.dart';

abstract interface class AddressesRepository {
  Future<List<SavedAddress>> getAddresses();

  Future<SavedAddress?> getDefaultAddress();

  Future<List<SavedAddress>> saveAddress(SavedAddress address);

  Future<List<SavedAddress>> removeAddress(String id);

  Future<List<SavedAddress>> setDefault(String id);
}
