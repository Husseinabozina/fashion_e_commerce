import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  void useEnglish() => emit(const Locale('en'));

  void useArabic() => emit(const Locale('ar'));
}
