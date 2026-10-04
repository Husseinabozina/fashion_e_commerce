import 'package:fashion_e_commerce/features/onboarding/domain/entities/shopping_preferences.dart';

abstract interface class PreferencesDataSource {
  Future<ShoppingPreferences> read();

  Future<ShoppingPreferences> save(
    ShoppingPreferences preferences,
  );
}
