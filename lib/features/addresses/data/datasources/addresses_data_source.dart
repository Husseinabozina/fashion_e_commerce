import 'package:fashion_e_commerce/features/addresses/domain/entities/saved_address.dart';

abstract interface class AddressesDataSource {
  Future<List<SavedAddress>> readAll();

  Future<SavedAddress?> readDefault();

  Future<List<SavedAddress>> save(SavedAddress address);

  Future<List<SavedAddress>> remove(String id);

  Future<List<SavedAddress>> setDefault(String id);
}
