import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/catalog/data/models/product_model.dart';
import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import '../models/cart_item_mapper.dart';
import 'cart_data_source.dart';

class FirestoreCartDataSource implements CartDataSource {
  FirestoreCartDataSource(this.store);
  final FirebaseAccountStore store;
  @override
  Future<List<CartItem>> read() async {
    final result = await store.collection('cart').get();
    final items = <CartItem>[];
    for (final doc in result.docs) {
      final data = doc.data();
      final product = await store.db
          .collection('products')
          .doc(data['productId'] as String)
          .get();
      if (!product.exists) continue;
      items.add(CartItem(
          product: ProductModel.fromMap(product.id, product.data()!),
          color: data['color'] as String,
          size: data['size'] as String,
          quantity: data['quantity'] as int));
    }
    return items;
  }

  @override
  Future<List<CartItem>> add(CartItem item) async {
    final ref = store
        .collection('cart')
        .doc(FirebaseAccountStore.documentKey(item.key));
    await store.db.runTransaction((tx) async {
      final current = await tx.get(ref);
      final quantity =
          (current.data()?['quantity'] as int? ?? 0) + item.quantity;
      if (quantity < 1 || quantity > 99)
        throw StateError('Quantity must be between 1 and 99.');
      tx.set(ref, {...CartItemMapper.reference(item), 'quantity': quantity});
    });
    return read();
  }

  @override
  Future<List<CartItem>> updateQuantity(String key, int quantity) async {
    final ref =
        store.collection('cart').doc(FirebaseAccountStore.documentKey(key));
    if (quantity <= 0) {
      await ref.delete();
    } else {
      if (quantity > 99) throw StateError('Quantity must be between 1 and 99.');
      await ref.update({'quantity': quantity});
    }
    return read();
  }

  @override
  Future<List<CartItem>> remove(String key) async {
    await store
        .collection('cart')
        .doc(FirebaseAccountStore.documentKey(key))
        .delete();
    return read();
  }

  @override
  Future<void> clear() async {
    final result = await store.collection('cart').get();
    final batch = store.db.batch();
    for (final doc in result.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
