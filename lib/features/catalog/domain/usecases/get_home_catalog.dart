import 'package:fashion_e_commerce/features/catalog/domain/entities/home_catalog.dart';
import 'package:fashion_e_commerce/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/repositories/preferences_repository.dart';

class GetHomeCatalog {
  const GetHomeCatalog(
    this._catalogRepository,
    this._preferencesRepository,
  );

  final CatalogRepository _catalogRepository;
  final PreferencesRepository _preferencesRepository;

  Future<HomeCatalog> call() async {
    final catalog = await _catalogRepository.getHomeCatalog();
    final preferences = await _preferencesRepository.getPreferences();

    if (preferences.interests.isEmpty) {
      return catalog;
    }

    final products = List.of(catalog.newArrivals)
      ..sort((a, b) {
        final aPreferred = preferences.interests.contains(a.category);
        final bPreferred = preferences.interests.contains(b.category);

        if (aPreferred == bPreferred) return 0;
        return aPreferred ? -1 : 1;
      });

    final categories = List.of(catalog.categories)
      ..sort((a, b) {
        final aPreferred = preferences.interests.contains(a);
        final bPreferred = preferences.interests.contains(b);

        if (aPreferred == bPreferred) return 0;
        return aPreferred ? -1 : 1;
      });

    return HomeCatalog(
      heroProduct: products.first,
      newArrivals: products,
      categories: categories,
    );
  }
}
