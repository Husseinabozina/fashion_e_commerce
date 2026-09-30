import 'package:fashion_e_commerce/features/promotions/data/datasources/promotions_data_source.dart';
import 'package:fashion_e_commerce/features/promotions/domain/entities/promotion.dart';
import 'package:fashion_e_commerce/features/promotions/domain/repositories/promotions_repository.dart';

class PromotionsRepositoryImpl implements PromotionsRepository {
  const PromotionsRepositoryImpl(this._dataSource);

  final PromotionsDataSource _dataSource;

  @override
  Future<Promotion?> getAppliedPromotion() => _dataSource.readApplied();

  @override
  Future<Promotion> applyCode({
    required String code,
    required double subtotal,
  }) {
    return _dataSource.apply(code: code, subtotal: subtotal);
  }

  @override
  Future<void> clearPromotion() => _dataSource.clear();
}
