import 'package:fashion_e_commerce/features/addresses/data/datasources/addresses_data_source.dart';
import 'package:fashion_e_commerce/features/addresses/domain/entities/saved_address.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/shipping_address.dart';

class InMemoryAddressesDataSource implements AddressesDataSource {
  final List<SavedAddress> _addresses = <SavedAddress>[
    const SavedAddress(
      id: 'address-home',
      label: 'Home',
      isDefault: true,
      address: ShippingAddress(
        fullName: 'NOVA Customer',
        phone: '01000000000',
        city: 'Cairo',
        area: 'New Cairo',
        street: 'Street 90',
        building: '12',
      ),
    ),
  ];

  @override
  Future<List<SavedAddress>> readAll() async {
    return List<SavedAddress>.unmodifiable(_addresses);
  }

  @override
  Future<SavedAddress?> readDefault() async {
    for (final address in _addresses) {
      if (address.isDefault) return address;
    }

    return _addresses.isEmpty ? null : _addresses.first;
  }

  @override
  Future<List<SavedAddress>> save(SavedAddress address) async {
    final index = _addresses.indexWhere((item) => item.id == address.id);

    if (index == -1) {
      final shouldDefault = _addresses.isEmpty || address.isDefault;
      if (shouldDefault) {
        _clearDefaults();
      }
      _addresses.add(address.copyWith(isDefault: shouldDefault));
    } else {
      if (address.isDefault) {
        _clearDefaults();
      }
      _addresses[index] = address;
    }

    return readAll();
  }

  @override
  Future<List<SavedAddress>> remove(String id) async {
    final wasDefault =
        _addresses.any((item) => item.id == id && item.isDefault);
    _addresses.removeWhere((item) => item.id == id);

    if (wasDefault && _addresses.isNotEmpty) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }

    return readAll();
  }

  @override
  Future<List<SavedAddress>> setDefault(String id) async {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(
        isDefault: _addresses[i].id == id,
      );
    }

    return readAll();
  }

  void _clearDefaults() {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: false);
    }
  }
}
