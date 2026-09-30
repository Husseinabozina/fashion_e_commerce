import 'package:fashion_e_commerce/features/promotions/domain/entities/promotion.dart';

abstract interface class PromotionsDataSource {
  Future<Promotion?> readApplied();

  Future<Promotion> apply({
    required String code,
    required double subtotal,
  });

  Future<void> clear();
}
