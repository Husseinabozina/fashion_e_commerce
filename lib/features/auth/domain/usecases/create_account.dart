import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class CreateAccount {
  const CreateAccount(this.repository);
  final AuthRepository repository;
  Future<AppUser> call(
          {required String name,
          required String email,
          required String password}) =>
      repository.createAccount(name: name, email: email, password: password);
}
