import 'package:fashion_e_commerce/features/auth/domain/entities/app_user.dart';

abstract interface class AuthRepository {
  Future<AppUser> getCurrentUser();

  Stream<AppUser> watchUser();

  Future<AppUser> createAccount(
      {required String name, required String email, required String password});

  Future<void> resetPassword(String email);

  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<AppUser> signOut();
}
