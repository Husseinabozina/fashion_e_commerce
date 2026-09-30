import 'package:fashion_e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/get_current_user.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/sign_in.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/sign_out.dart';
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
  const AuthFailure(this.message);

  final String message;
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._getCurrentUser,
    this._signIn,
    this._signOut,
  ) : super(const AuthLoading());

  final GetCurrentUser _getCurrentUser;
  final SignIn _signIn;
  final SignOut _signOut;

  Future<void> load() async {
    emit(const AuthLoading());
    try {
      emit(AuthReady(await _getCurrentUser()));
    } catch (_) {
      emit(const AuthFailure('Account could not be loaded.'));
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      emit(
        AuthReady(
          await _signIn(
            email: email,
            password: password,
          ),
        ),
      );
      return true;
    } catch (_) {
      emit(const AuthFailure('Check your email and password.'));
      return false;
    }
  }

  Future<void> signOut() async {
    emit(AuthReady(await _signOut()));
  }
}
