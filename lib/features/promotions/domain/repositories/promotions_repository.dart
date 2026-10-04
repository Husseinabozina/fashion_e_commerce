import 'package:fashion_e_commerce/features/promotions/domain/entities/promotion.dart';

abstract interface class PromotionsRepository {
  Future<Promotion?> getAppliedPromotion();

  Future<Promotion> applyCode({
    required String code,
    required double subtotal,
  });

  Future<void> clearPromotion();
}
