import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/promotions/domain/entities/promotion.dart';
import 'promotions_data_source.dart';

class FirestorePromotionsDataSource implements PromotionsDataSource {
  FirestorePromotionsDataSource(this.store);
  final FirebaseAccountStore store;
  Promotion _decode(String code, Map<String, dynamic> d) => Promotion(
      code: code,
      title: d['title'] as String,
      type: DiscountType.values.byName(d['type'] as String),
      value: (d['value'] as num).toDouble(),
      minimumSubtotal: (d['minimumSubtotal'] as num).toDouble(),
      maximumDiscount: (d['maximumDiscount'] as num?)?.toDouble());
  @override
  Future<Promotion?> readApplied() async {
    final selected = await store.collection('settings').doc('promotion').get();
    final code = selected.data()?['code'] as String?;
    if (code == null) return null;
    final promotion = await store.db.collection('promotions').doc(code).get();
    return promotion.exists ? _decode(code, promotion.data()!) : null;
  }

  @override
  Future<Promotion> apply(
      {required String code, required double subtotal}) async {
    final normalized = code.trim().toUpperCase();
    final selected = store.collection('settings').doc('promotion');
    final doc = await store.db.collection('promotions').doc(normalized).get();
    if (!doc.exists) throw StateError('Invalid promotion code.');
    final promotion = _decode(normalized, doc.data()!);
    if (subtotal < promotion.minimumSubtotal)
      throw StateError(
          'Minimum subtotal is ${promotion.minimumSubtotal.toStringAsFixed(0)} EGP.');
    await selected.set({'code': normalized});
    return promotion;
  }

  @override
  Future<void> clear() =>
      store.collection('settings').doc('promotion').delete();
}
