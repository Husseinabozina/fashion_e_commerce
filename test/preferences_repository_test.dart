import 'package:fashion_e_commerce/features/catalog/data/datasources/demo_catalog_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_home_catalog.dart';
import 'package:fashion_e_commerce/features/onboarding/data/datasources/in_memory_preferences_data_source.dart';
import 'package:fashion_e_commerce/features/onboarding/data/repositories/preferences_repository_impl.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/entities/shopping_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preferences persist onboarding and personalize home ordering', () async {
    final preferences = PreferencesRepositoryImpl(
      InMemoryPreferencesDataSource(),
    );

    await preferences.savePreferences(
      const ShoppingPreferences(
        hasCompletedOnboarding: true,
        interests: <String>{'Hoodies'},
      ),
    );

    final getHome = GetHomeCatalog(
      CatalogRepositoryImpl(DemoCatalogDataSource()),
      preferences,
    );

    final home = await getHome();

    expect(home.categories.first, 'Hoodies');
    expect(home.heroProduct.category, 'Hoodies');

    final stored = await preferences.getPreferences();
    expect(stored.hasCompletedOnboarding, isTrue);
    expect(stored.interests, contains('Hoodies'));
  });
}
