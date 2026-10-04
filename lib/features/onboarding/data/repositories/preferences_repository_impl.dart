import 'package:fashion_e_commerce/features/onboarding/data/datasources/preferences_data_source.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/entities/shopping_preferences.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/repositories/preferences_repository.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  const PreferencesRepositoryImpl(this._dataSource);

  final PreferencesDataSource _dataSource;

  @override
  Future<ShoppingPreferences> getPreferences() {
    return _dataSource.read();
  }

  @override
  Future<ShoppingPreferences> savePreferences(
    ShoppingPreferences preferences,
  ) {
    return _dataSource.save(preferences);
  }
}
