import 'package:fashion_e_commerce/core/localization/locale_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('locale switches between English and Arabic', () {
    final cubit = LocaleCubit();

    expect(cubit.state.languageCode, 'en');

    cubit.useArabic();
    expect(cubit.state.languageCode, 'ar');

    cubit.useEnglish();
    expect(cubit.state.languageCode, 'en');

    cubit.close();
  });
}
