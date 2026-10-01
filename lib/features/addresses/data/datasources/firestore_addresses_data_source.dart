import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/addresses/domain/entities/saved_address.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/shipping_address.dart';
import 'addresses_data_source.dart';

class FirestoreAddressesDataSource implements AddressesDataSource {
  FirestoreAddressesDataSource(this.store);
  final FirebaseAccountStore store;
  @override
  Future<List<SavedAddress>> readAll() async {
    final addresses = store.collection('addresses');
    final defaults =
        addresses.parent!.collection('settings').doc('defaultAddress');
    final docs = await addresses.get();
    final selected = (await defaults.get()).data()?['addressId'];
    return docs.docs.map((doc) {
      final d = doc.data();
      return SavedAddress(
          id: doc.id,
          label: d['label'] as String,
          isDefault: doc.id == selected,
          address: ShippingAddress(
              fullName: d['fullName'] as String,
              phone: d['phone'] as String,
              city: d['city'] as String,
              area: d['area'] as String,
              street: d['street'] as String,
              building: d['building'] as String,
              notes: d['notes'] as String));
    }).toList();
  }

  @override
  Future<SavedAddress?> readDefault() async {
    final items = await readAll();
    for (final item in items) {
      if (item.isDefault) return item;
    }
    return items.isEmpty ? null : items.first;
  }

  @override
  Future<List<SavedAddress>> save(SavedAddress address) async {
    final addresses = store.collection('addresses');
    final selected =
        addresses.parent!.collection('settings').doc('defaultAddress');
    final a = address.address;
    await store.db.runTransaction((tx) async {
      final previous = await tx.get(selected);
      tx.set(addresses.doc(address.id), {
        'label': address.label,
        'fullName': a.fullName,
        'phone': a.phone,
        'city': a.city,
        'area': a.area,
        'street': a.street,
        'building': a.building,
        'notes': a.notes
      });
      if (!previous.exists || address.isDefault)
        tx.set(selected, {'addressId': address.id});
    });
    return readAll();
  }

  @override
  Future<List<SavedAddress>> remove(String id) async {
    final addresses = store.collection('addresses');
    final selected =
        addresses.parent!.collection('settings').doc('defaultAddress');
    await store.db.runTransaction((tx) async {
      final previous = await tx.get(selected);
      tx.delete(addresses.doc(id));
      if (previous.data()?['addressId'] == id) tx.delete(selected);
    });
    return readAll();
  }

  @override
  Future<List<SavedAddress>> setDefault(String id) async {
    final addresses = store.collection('addresses');
    if (!(await addresses.doc(id).get()).exists)
      throw StateError('Address not found.');
    await addresses.parent!
        .collection('settings')
        .doc('defaultAddress')
        .set({'addressId': id});
    return readAll();
  }
}
