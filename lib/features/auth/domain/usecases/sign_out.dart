import 'package:fashion_e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:fashion_e_commerce/features/auth/domain/repositories/auth_repository.dart';

class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call() => _repository.signOut();
}
