import 'package:fashion_e_commerce/features/promotions/domain/entities/promotion.dart';
import 'package:fashion_e_commerce/features/promotions/domain/usecases/apply_promotion_code.dart';
import 'package:fashion_e_commerce/features/promotions/domain/usecases/clear_promotion.dart';
import 'package:fashion_e_commerce/features/promotions/domain/usecases/get_applied_promotion.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class PromotionsState {
  const PromotionsState();
}

final class PromotionsLoading extends PromotionsState {
  const PromotionsLoading();
}

final class PromotionsReady extends PromotionsState {
  const PromotionsReady({
    this.applied,
    this.message,
    this.hasError = false,
  });

  final Promotion? applied;
  final String? message;
  final bool hasError;

  double discountFor(double subtotal) {
    return applied?.discountFor(subtotal) ?? 0;
  }
}

class PromotionsCubit extends Cubit<PromotionsState> {
  PromotionsCubit(
    this._getAppliedPromotion,
    this._applyPromotionCode,
    this._clearPromotion,
  ) : super(const PromotionsLoading());

  final GetAppliedPromotion _getAppliedPromotion;
  final ApplyPromotionCode _applyPromotionCode;
  final ClearPromotion _clearPromotion;

  Future<void> load() async {
    emit(
      PromotionsReady(
        applied: await _getAppliedPromotion(),
      ),
    );
  }

  Future<void> apply({
    required String code,
    required double subtotal,
  }) async {
    try {
      final promotion = await _applyPromotionCode(
        code: code,
        subtotal: subtotal,
      );

      emit(
        PromotionsReady(
          applied: promotion,
          message: promotion.code + ' applied.',
        ),
      );
    } catch (error) {
      final current = state;
      emit(
        PromotionsReady(
          applied: current is PromotionsReady ? current.applied : null,
          message: error.toString().replaceFirst('Bad state: ', ''),
          hasError: true,
        ),
      );
    }
  }

  Future<void> clear() async {
    await _clearPromotion();
    emit(const PromotionsReady());
  }
}
