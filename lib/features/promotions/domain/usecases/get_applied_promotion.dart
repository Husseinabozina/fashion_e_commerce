import 'package:fashion_e_commerce/features/promotions/domain/entities/promotion.dart';
import 'package:fashion_e_commerce/features/promotions/domain/repositories/promotions_repository.dart';

class GetAppliedPromotion {
  const GetAppliedPromotion(this._repository);

  final PromotionsRepository _repository;

  Future<Promotion?> call() => _repository.getAppliedPromotion();
}
