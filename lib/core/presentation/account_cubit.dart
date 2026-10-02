import 'package:flutter_bloc/flutter_bloc.dart';

/// Discards completions from a screen disposed during an account transition.
abstract class AccountCubit<S> extends Cubit<S> {
  AccountCubit(super.initialState);
  @override
  void emit(S state) {
    if (!isClosed) super.emit(state);
  }
}
