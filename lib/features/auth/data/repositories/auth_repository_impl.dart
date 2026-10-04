import 'package:fashion_e_commerce/features/auth/data/datasources/auth_data_source.dart';
import 'package:fashion_e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:fashion_e_commerce/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  Stream<AppUser> watchUser() => _dataSource.watchUser();

  @override
  Future<AppUser> createAccount(
          {required String name,
          required String email,
          required String password}) =>
      _dataSource.createAccount(name: name, email: email, password: password);

  @override
  Future<void> resetPassword(String email) => _dataSource.resetPassword(email);

  @override
  Future<AppUser> getCurrentUser() => _dataSource.currentUser();

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) {
    return _dataSource.signIn(email: email, password: password);
  }

  @override
  Future<AppUser> signOut() => _dataSource.signOut();
}
