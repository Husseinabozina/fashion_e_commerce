import 'package:fashion_e_commerce/features/addresses/data/datasources/in_memory_addresses_data_source.dart';
import 'package:fashion_e_commerce/features/addresses/data/repositories/addresses_repository_impl.dart';
import 'package:fashion_e_commerce/features/addresses/domain/entities/saved_address.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/shipping_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('address book supports add, default and remove', () async {
    final repository = AddressesRepositoryImpl(
      InMemoryAddressesDataSource(),
    );

    final initial = await repository.getDefaultAddress();
    expect(initial, isNotNull);
    expect(initial!.isDefault, isTrue);

    const office = SavedAddress(
      id: 'office',
      label: 'Office',
      address: ShippingAddress(
        fullName: 'Test User',
        phone: '01011111111',
        city: 'Cairo',
        area: 'Downtown',
        street: 'Test Street',
        building: '4',
      ),
    );

    await repository.saveAddress(office);
    await repository.setDefault('office');

    final selected = await repository.getDefaultAddress();
    expect(selected?.id, 'office');

    final remaining = await repository.removeAddress('office');
    expect(remaining.any((item) => item.id == 'office'), isFalse);
    expect(remaining.first.isDefault, isTrue);
  });
}
