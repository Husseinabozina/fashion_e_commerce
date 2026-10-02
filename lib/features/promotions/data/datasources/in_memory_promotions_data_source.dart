import 'package:fashion_e_commerce/features/promotions/data/datasources/promotions_data_source.dart';
import 'package:fashion_e_commerce/features/promotions/domain/entities/promotion.dart';

class InMemoryPromotionsDataSource implements PromotionsDataSource {
  static const List<Promotion> _available = <Promotion>[
    Promotion(
      code: 'STREET10',
      title: 'Street Drop 10%',
      type: DiscountType.percentage,
      value: 10,
      minimumSubtotal: 1500,
      maximumDiscount: 700,
    ),
    Promotion(
      code: 'NOVA500',
      title: 'NOVA 500 EGP Off',
      type: DiscountType.fixed,
      value: 500,
      minimumSubtotal: 4000,
    ),
  ];

  Promotion? _applied;

  @override
  Future<Promotion?> readApplied() async => _applied;

  @override
  Future<Promotion> apply({
    required String code,
    required double subtotal,
  }) async {
    final normalized = code.trim().toUpperCase();

    Promotion? promotion;
    for (final item in _available) {
      if (item.code == normalized) {
        promotion = item;
        break;
      }
    }

    if (promotion == null) {
      throw StateError('Invalid promotion code.');
    }

    if (subtotal < promotion.minimumSubtotal) {
      throw StateError(
        'Minimum subtotal is ' +
            promotion.minimumSubtotal.toStringAsFixed(0) +
            ' EGP.',
      );
    }

    _applied = promotion;
    return promotion;
  }

  @override
  Future<void> clear() async {
    _applied = null;
  }
}
