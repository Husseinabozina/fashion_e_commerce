import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/reviews/domain/entities/product_review.dart';
import 'reviews_data_source.dart';

class FirestoreReviewsDataSource implements ReviewsDataSource {
  FirestoreReviewsDataSource(this.store);
  final FirebaseAccountStore store;
  @override
  Future<List<ProductReview>> read(String productId) async {
    final docs = await store.db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .get();
    final items = docs.docs.map((doc) {
      final d = doc.data();
      return ProductReview(
          id: doc.id,
          productId: productId,
          authorName: d['authorName'] as String,
          rating: d['rating'] as int,
          comment: d['comment'] as String,
          fit: FitFeedback.values.byName(d['fit'] as String),
          createdAt: (d['createdAt'] as Timestamp).toDate(),
          verifiedPurchase: d['verifiedPurchase'] as bool);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<ProductReview> add(ProductReview review) async {
    final user = store.auth.currentUser!;
    if (user.isAnonymous) throw StateError('Sign in to write a review.');
    final author = user.displayName ?? 'NOVA Member';
    final ref = store.db
        .collection('products')
        .doc(review.productId)
        .collection('reviews')
        .doc(user.uid);
    await store.db.runTransaction((tx) async {
      final previous = await tx.get(ref);
      tx.set(ref, {
        'authorUid': user.uid,
        'authorName': author,
        'rating': review.rating,
        'comment': review.comment,
        'fit': review.fit.name,
        'createdAt':
            previous.data()?['createdAt'] ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'verifiedPurchase': false
      });
    });
    return (await read(review.productId))
        .firstWhere((item) => item.id == user.uid);
  }
}
