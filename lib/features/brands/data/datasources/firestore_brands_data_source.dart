import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/brands/domain/entities/brand.dart';
import 'brands_data_source.dart';

class FirestoreBrandsDataSource implements BrandsDataSource {
  FirestoreBrandsDataSource(this.store);
  final FirebaseAccountStore store;
  Future<List<Brand>> _brands() async {
    final docs = await store.db.collection('brands').get();
    return docs.docs
        .map((doc) => Brand(
            id: doc.id,
            name: doc.data()['name'] as String,
            tagline: doc.data()['tagline'] as String,
            description: doc.data()['description'] as String))
        .toList();
  }

  @override
  Future<Brand> readByName(String name) async => (await _brands())
      .firstWhere((brand) => brand.name == name.trim().toUpperCase());
  @override
  Future<List<Brand>> readFollowing() async {
    final following = (await store.collection('following').get())
        .docs
        .map((doc) => doc.id)
        .toSet();
    return (await _brands())
        .where((brand) => following.contains(brand.id))
        .toList();
  }

  @override
  Future<bool> isFollowing(String brandId) async =>
      (await store.collection('following').doc(brandId).get()).exists;
  @override
  Future<bool> toggleFollow(String brandId) async {
    final ref = store.collection('following').doc(brandId);
    return store.db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (doc.exists) {
        tx.delete(ref);
        return false;
      }
      tx.set(ref, {'brandId': brandId});
      return true;
    });
  }
}
