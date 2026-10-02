import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/data/models/product_model.dart';
import 'wishlist_data_source.dart';

class FirestoreWishlistDataSource implements WishlistDataSource {
  FirestoreWishlistDataSource(this.store);
  final FirebaseAccountStore store;
  @override
  Future<List<Product>> read() async {
    final saved = await store.collection('wishlist').get();
    final products = <Product>[];
    for (final item in saved.docs) {
      final doc = await store.db.collection('products').doc(item.id).get();
      if (doc.exists) products.add(ProductModel.fromMap(doc.id, doc.data()!));
    }
    return products;
  }

  @override
  Future<List<Product>> toggle(Product product) async {
    final ref = store.collection('wishlist').doc(product.id);
    await store.db.runTransaction((tx) async {
      final current = await tx.get(ref);
      if (current.exists) {
        tx.delete(ref);
      } else {
        tx.set(ref, {'productId': product.id});
      }
    });
    return read();
  }
}
