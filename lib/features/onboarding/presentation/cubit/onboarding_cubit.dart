import 'package:fashion_e_commerce/features/onboarding/domain/entities/shopping_preferences.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/usecases/save_shopping_preferences.dart';
import 'package:fashion_e_commerce/core/presentation/account_cubit.dart';

class OnboardingState {
  const OnboardingState({
    this.interests = const <String>{},
    this.isSaving = false,
  });

  final Set<String> interests;
  final bool isSaving;

  OnboardingState copyWith({
    Set<String>? interests,
    bool? isSaving,
  }) {
    return OnboardingState(
      interests: interests ?? this.interests,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class OnboardingCubit extends AccountCubit<OnboardingState> {
  OnboardingCubit(this._saveShoppingPreferences)
      : super(const OnboardingState());

  final SaveShoppingPreferences _saveShoppingPreferences;

  void toggleInterest(String interest) {
    final next = Set<String>.from(state.interests);
    if (!next.add(interest)) {
      next.remove(interest);
    }

    emit(state.copyWith(interests: next));
  }

  Future<void> complete() async {
    try {
      emit(state.copyWith(isSaving: true));

      await _saveShoppingPreferences(
        ShoppingPreferences(
          hasCompletedOnboarding: true,
          interests: state.interests,
        ),
      );

      emit(state.copyWith(isSaving: false));
    } catch (_) {
      rethrow;
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  Future<void> skip() async {
    try {
      emit(state.copyWith(isSaving: true));

      await _saveShoppingPreferences(
        const ShoppingPreferences(
          hasCompletedOnboarding: true,
        ),
      );

      emit(const OnboardingState());
    } catch (_) {
      rethrow;
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }
}
