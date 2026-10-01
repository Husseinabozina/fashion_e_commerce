import 'package:fashion_e_commerce/features/onboarding/data/datasources/preferences_data_source.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/entities/shopping_preferences.dart';

class InMemoryPreferencesDataSource implements PreferencesDataSource {
  ShoppingPreferences _preferences =
      const ShoppingPreferences.initial();

  @override
  Future<ShoppingPreferences> read() async => _preferences;

  @override
  Future<ShoppingPreferences> save(
    ShoppingPreferences preferences,
  ) async {
    _preferences = preferences;
    return _preferences;
  }
}
