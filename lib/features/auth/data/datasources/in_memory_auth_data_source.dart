import 'package:fashion_e_commerce/features/auth/data/datasources/auth_data_source.dart';
import 'package:fashion_e_commerce/features/auth/domain/entities/app_user.dart';

class InMemoryAuthDataSource implements AuthDataSource {
  AppUser _current = const AppUser.guest();

  @override
  Stream<AppUser> watchUser() => const Stream.empty();

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<AppUser> createAccount(
      {required String name,
      required String email,
      required String password}) async {
    await signIn(email: email, password: password);
    _current = AppUser(
        id: _current.id,
        name: name.trim(),
        email: _current.email,
        isGuest: false);
    return _current;
  }

  @override
  Future<AppUser> currentUser() async => _current;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || password.length < 4) {
      throw StateError('Invalid credentials');
    }

    final localPart = normalized.split('@').first;
    final displayName = localPart
        .split(RegExp(r'[._-]'))
        .where((value) => value.isNotEmpty)
        .map((value) => value[0].toUpperCase() + value.substring(1))
        .join(' ');

    _current = AppUser(
      id: 'member-' + normalized,
      name: displayName.isEmpty ? 'NOVA Member' : displayName,
      email: normalized,
      isGuest: false,
    );

    return _current;
  }

  @override
  Future<AppUser> signOut() async {
    _current = const AppUser.guest();
    return _current;
  }
}
