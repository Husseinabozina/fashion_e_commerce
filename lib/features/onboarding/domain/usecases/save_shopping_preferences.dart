import 'package:fashion_e_commerce/features/onboarding/domain/entities/shopping_preferences.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/repositories/preferences_repository.dart';

class SaveShoppingPreferences {
  const SaveShoppingPreferences(this._repository);

  final PreferencesRepository _repository;

  Future<ShoppingPreferences> call(
    ShoppingPreferences preferences,
  ) {
    return _repository.savePreferences(preferences);
  }
}
