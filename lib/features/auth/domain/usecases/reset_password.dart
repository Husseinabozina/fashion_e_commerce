import '../repositories/auth_repository.dart';

class ResetPassword {
  const ResetPassword(this.repository);
  final AuthRepository repository;
  Future<void> call(String email) => repository.resetPassword(email);
}
