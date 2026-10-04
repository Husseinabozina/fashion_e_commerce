import 'package:fashion_e_commerce/features/promotions/domain/entities/promotion.dart';
import 'package:fashion_e_commerce/features/promotions/domain/repositories/promotions_repository.dart';

class ApplyPromotionCode {
  const ApplyPromotionCode(this._repository);

  final PromotionsRepository _repository;

  Future<Promotion> call({
    required String code,
    required double subtotal,
  }) {
    return _repository.applyCode(code: code, subtotal: subtotal);
  }
}
