import 'package:fashion_e_commerce/features/addresses/data/datasources/addresses_data_source.dart';
import 'package:fashion_e_commerce/features/addresses/domain/entities/saved_address.dart';
import 'package:fashion_e_commerce/features/addresses/domain/repositories/addresses_repository.dart';

class AddressesRepositoryImpl implements AddressesRepository {
  const AddressesRepositoryImpl(this._dataSource);

  final AddressesDataSource _dataSource;

  @override
  Future<List<SavedAddress>> getAddresses() => _dataSource.readAll();

  @override
  Future<SavedAddress?> getDefaultAddress() => _dataSource.readDefault();

  @override
  Future<List<SavedAddress>> saveAddress(SavedAddress address) {
    return _dataSource.save(address);
  }

  @override
  Future<List<SavedAddress>> removeAddress(String id) {
    return _dataSource.remove(id);
  }

  @override
  Future<List<SavedAddress>> setDefault(String id) {
    return _dataSource.setDefault(id);
  }
}
