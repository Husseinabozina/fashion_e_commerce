import 'package:fashion_e_commerce/features/promotions/data/datasources/in_memory_promotions_data_source.dart';
import 'package:fashion_e_commerce/features/promotions/data/repositories/promotions_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('percentage promotion respects minimum and maximum discount', () async {
    final repository = PromotionsRepositoryImpl(
      InMemoryPromotionsDataSource(),
    );

    final promotion = await repository.applyCode(
      code: 'street10',
      subtotal: 8000,
    );

    expect(promotion.code, 'STREET10');
    expect(promotion.discountFor(8000), 700);
  });

  test('fixed promotion applies exact discount', () async {
    final repository = PromotionsRepositoryImpl(
      InMemoryPromotionsDataSource(),
    );

    final promotion = await repository.applyCode(
      code: 'NOVA500',
      subtotal: 5000,
    );

    expect(promotion.discountFor(5000), 500);
  });

  test('promotion rejects subtotal below minimum', () async {
    final repository = PromotionsRepositoryImpl(
      InMemoryPromotionsDataSource(),
    );

    expect(
      () => repository.applyCode(
        code: 'NOVA500',
        subtotal: 3000,
      ),
      throwsStateError,
    );
  });
}
