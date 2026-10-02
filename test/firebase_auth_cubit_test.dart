import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fashion_e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:fashion_e_commerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/get_current_user.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/sign_in.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/sign_out.dart';
import 'package:fashion_e_commerce/features/auth/presentation/cubit/auth_cubit.dart';

void main() {
  test('auth stream events cannot reopen submission while sign-in is pending',
      () async {
    final repository = _PendingAuth();
    final cubit = AuthCubit(
        GetCurrentUser(repository), SignIn(repository), SignOut(repository),
        users: repository.watchUser(), isDemo: false);
    await cubit.load();
    final first =
        cubit.signIn(email: 'member@example.com', password: 'password123');
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, isA<AuthLoading>());
    expect(
        await cubit.signIn(
            email: 'member@example.com', password: 'password123'),
        isFalse);
    expect(repository.calls, 1);
    repository.gate.complete();
    expect(await first, isTrue);
    expect(cubit.state, isA<AuthReady>());
    await cubit.close();
    await repository.users.close();
  });
}

class _PendingAuth implements AuthRepository {
  final gate = Completer<void>();
  final users = StreamController<AppUser>.broadcast();
  int calls = 0;
  static const member = AppUser(
      id: 'member',
      name: 'Member',
      email: 'member@example.com',
      isGuest: false);
  @override
  Future<AppUser> getCurrentUser() async => const AppUser.guest();
  @override
  Stream<AppUser> watchUser() => users.stream;
  @override
  Future<AppUser> signIn(
      {required String email, required String password}) async {
    calls++;
    users.add(member);
    await gate.future;
    return member;
  }

  @override
  Future<AppUser> createAccount(
          {required String name,
          required String email,
          required String password}) =>
      throw UnimplementedError();
  @override
  Future<void> resetPassword(String email) => throw UnimplementedError();
  @override
  Future<AppUser> signOut() => throw UnimplementedError();
}
