import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/entities/shopping_preferences.dart';
import 'preferences_data_source.dart';

class FirestorePreferencesDataSource implements PreferencesDataSource {
  FirestorePreferencesDataSource(this.store);
  final FirebaseAccountStore store;
  @override
  Future<ShoppingPreferences> read() async {
    final doc = await store.collection('settings').doc('shopping').get();
    final d = doc.data();
    if (d == null) return const ShoppingPreferences.initial();
    return ShoppingPreferences(
        hasCompletedOnboarding: d['hasCompletedOnboarding'] as bool,
        interests: Set<String>.from(d['interests'] as List));
  }

  @override
  Future<ShoppingPreferences> save(ShoppingPreferences preferences) async {
    await store.collection('settings').doc('shopping').set({
      'hasCompletedOnboarding': preferences.hasCompletedOnboarding,
      'interests': preferences.interests.toList()
    });
    return preferences;
  }
}
