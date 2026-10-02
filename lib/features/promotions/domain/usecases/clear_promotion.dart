import 'package:fashion_e_commerce/features/promotions/domain/repositories/promotions_repository.dart';

class ClearPromotion {
  const ClearPromotion(this._repository);

  final PromotionsRepository _repository;

  Future<void> call() => _repository.clearPromotion();
}
