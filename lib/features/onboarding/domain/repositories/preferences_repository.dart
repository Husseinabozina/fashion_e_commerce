import 'package:fashion_e_commerce/features/onboarding/domain/entities/shopping_preferences.dart';

abstract interface class PreferencesRepository {
  Future<ShoppingPreferences> getPreferences();

  Future<ShoppingPreferences> savePreferences(
    ShoppingPreferences preferences,
  );
}
