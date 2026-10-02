import 'dart:async';
import 'package:fashion_e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:fashion_e_commerce/features/auth/domain/entities/auth_exception.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/get_current_user.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/sign_in.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/sign_out.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/create_account.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/reset_password.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AuthState {
  const AuthState();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthReady extends AuthState {
  const AuthReady(this.user);
  final AppUser user;
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.message, {this.code = 'unknown'});
  final String message;
  final String code;
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._getCurrentUser, this._signIn, this._signOut,
      {CreateAccount? createAccount,
      ResetPassword? resetPassword,
      Stream<AppUser>? users,
      this.isDemo = true})
      : _createAccount = createAccount,
        _resetPassword = resetPassword,
        super(const AuthLoading()) {
    _subscription =
        users?.listen(_observe, onError: (Object error) => _failure(error));
  }
  final GetCurrentUser _getCurrentUser;
  final SignIn _signIn;
  final SignOut _signOut;
  final CreateAccount? _createAccount;
  final ResetPassword? _resetPassword;
  final bool isDemo;
  StreamSubscription<AppUser>? _subscription;
  bool _busy = false;
  AppUser _user = const AppUser.guest();
  String get sessionKey => _user.id;
  void _observe(AppUser user) {
    _user = user;
    if (!isClosed) emit(_busy ? const AuthLoading() : AuthReady(user));
  }

  void _ready(AppUser user) {
    _busy = false;
    _user = user;
    if (!isClosed) emit(AuthReady(user));
  }

  void _failure(Object error) {
    _busy = false;
    if (!isClosed)
      emit(AuthFailure('Account action could not be completed.',
          code: error is AuthException ? error.code : 'unknown'));
  }

  Future<void> load() async {
    if (isClosed || _busy) return;
    _busy = true;
    emit(const AuthLoading());
    try {
      _ready(await _getCurrentUser());
    } catch (error) {
      _failure(error);
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    if (isClosed || _busy) return false;
    _busy = true;
    emit(const AuthLoading());
    try {
      _ready(await _signIn(email: email, password: password));
      return true;
    } catch (error) {
      _failure(error);
      return false;
    }
  }

  Future<bool> createAccount(
      {required String name,
      required String email,
      required String password}) async {
    if (isClosed || _busy || _createAccount == null) return false;
    _busy = true;
    emit(const AuthLoading());
    try {
      _ready(
          await _createAccount(name: name, email: email, password: password));
      return true;
    } catch (error) {
      _failure(error);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    if (isClosed || _busy || _resetPassword == null) return false;
    _busy = true;
    emit(const AuthLoading());
    try {
      await _resetPassword(email);
      _ready(_user);
      return true;
    } catch (error) {
      _failure(error);
      return false;
    }
  }

  Future<void> signOut() async {
    if (isClosed || _busy) return;
    _busy = true;
    emit(const AuthLoading());
    try {
      _ready(await _signOut());
    } catch (error) {
      _failure(error);
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
