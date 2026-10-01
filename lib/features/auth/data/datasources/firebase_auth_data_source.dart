import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashion_e_commerce/features/auth/data/datasources/auth_data_source.dart';
import 'package:fashion_e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:fashion_e_commerce/features/auth/domain/entities/auth_exception.dart';

class FirebaseAuthDataSource implements AuthDataSource {
  FirebaseAuthDataSource(this._auth);
  final FirebaseAuth _auth;

  static Future<User> ensureSession(FirebaseAuth auth) async =>
      auth.currentUser ?? (await auth.signInAnonymously()).user!;

  static AppUser mapUser(User user) => AppUser(
        id: user.uid,
        name: user.isAnonymous ? 'Guest' : (user.displayName ?? 'NOVA Member'),
        email: user.email ?? '',
        isGuest: user.isAnonymous,
      );

  @override
  Stream<AppUser> watchUser() => _auth
      .userChanges()
      .where((user) => user != null)
      .map((user) => mapUser(user!));

  @override
  Future<AppUser> currentUser() async => mapUser(await ensureSession(_auth));

  @override
  Future<AppUser> signIn(
      {required String email, required String password}) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      return mapUser(result.user!);
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.code);
    }
  }

  @override
  Future<AppUser> createAccount(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final current = await ensureSession(_auth);
      // Linking retains the guest's saved items, cart and addresses under its UID.
      final result = current.isAnonymous
          ? await current.linkWithCredential(EmailAuthProvider.credential(
              email: email.trim(), password: password))
          : await _auth.createUserWithEmailAndPassword(
              email: email.trim(), password: password);
      await result.user!.updateDisplayName(name.trim());
      await _auth.currentUser!.getIdToken(true);
      return mapUser(_auth.currentUser!);
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.code);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.code);
    }
  }

  @override
  Future<AppUser> signOut() async {
    await _auth.signOut();
    return currentUser();
  }
}
