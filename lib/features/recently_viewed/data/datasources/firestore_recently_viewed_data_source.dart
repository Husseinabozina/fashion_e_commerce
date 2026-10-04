import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/data/models/product_model.dart';
import 'recently_viewed_data_source.dart';

class FirestoreRecentlyViewedDataSource implements RecentlyViewedDataSource {
  FirestoreRecentlyViewedDataSource(this.store);
  final FirebaseAccountStore store;
  @override
  Future<List<Product>> read() async {
    final result = await store.collection('recentlyViewed').get();
    final docs = result.docs.toList()
      ..sort((a, b) => (b.data()['viewedAt'] as Timestamp)
          .compareTo(a.data()['viewedAt'] as Timestamp));
    final products = <Product>[];
    for (final item in docs.take(8)) {
      final product = await store.db.collection('products').doc(item.id).get();
      if (product.exists)
        products.add(ProductModel.fromMap(product.id, product.data()!));
    }
    return products;
  }

  @override
  Future<List<Product>> track(Product product) async {
    final collection = store.collection('recentlyViewed');
    await collection.doc(product.id).set(
        {'productId': product.id, 'viewedAt': FieldValue.serverTimestamp()});
    final result = await collection.get();
    final docs = result.docs.toList()
      ..sort((a, b) => (b.data()['viewedAt'] as Timestamp)
          .compareTo(a.data()['viewedAt'] as Timestamp));
    final batch = store.db.batch();
    for (final doc in docs.skip(8)) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    return read();
  }
}
