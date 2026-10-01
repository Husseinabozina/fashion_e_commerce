import 'support/network_images.dart';
import 'package:fashion_e_commerce/app/app.dart';
import 'package:fashion_e_commerce/core/config/app_constants.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/core/localization/locale_cubit.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/home_page.dart';
import 'package:fashion_e_commerce/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/search_page.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/search_cubit.dart';
import 'package:fashion_e_commerce/features/addresses/domain/usecases/get_addresses.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/product_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await serviceLocator.reset();
    configureDependencies();
  });
  tearDown(() async {
    await serviceLocator.reset();
  });
  for (final arabic in [false, true]) {
    testWidgets(
        '${arabic ? 'Arabic' : 'English'} forms and sheets work with large text and keyboard',
        (tester) => withTestImages(() async {
              tester.view.physicalSize = const Size(320, 640);
              tester.view.devicePixelRatio = 1;
              tester.platformDispatcher.textScaleFactorTestValue = 1.6;
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);
              addTearDown(tester.view.resetViewInsets);
              addTearDown(
                  tester.platformDispatcher.clearTextScaleFactorTestValue);
              await tester.pumpWidget(const FashionApp());
              await tester.pump();
              await tester.pump(AppConstants.initialSplashDuration);
              await tester.pump(const Duration(milliseconds: 250));
              await tester.pump(AppConstants.brandRevealDuration);
              await tester.pumpAndSettle();
              if (find.byType(OnboardingPage).evaluate().isNotEmpty) {
                await tester.scrollUntilVisible(find.text('SKIP FOR NOW'), 150);
                await tester.pumpAndSettle();
                await tester.ensureVisible(find.text('SKIP FOR NOW'));
                await tester.pumpAndSettle();
                await tester.tap(find.text('SKIP FOR NOW'));
                await tester.pumpAndSettle();
              }
              if (arabic) {
                tester
                    .element(find.byType(HomePage))
                    .read<LocaleCubit>()
                    .useArabic();
                await tester.pumpAndSettle();
              }
              final navigator =
                  Navigator.of(tester.element(find.byType(HomePage)));
              Future<void> tap(String label) async {
                final match = find.text(label);
                if (match.evaluate().isEmpty) {
                  await tester.scrollUntilVisible(match, 150,
                      scrollable: find
                          .byWidgetPredicate((widget) =>
                              widget is Scrollable &&
                              widget.axisDirection == AxisDirection.down)
                          .last);
                  await tester.pumpAndSettle();
                }
                final target = match.last;
                await tester.ensureVisible(target);
                await tester.pumpAndSettle();
                await tester.tap(target);
                await tester.pumpAndSettle();
                expect(tester.takeException(), isNull, reason: label);
              }

              navigator.pushNamed(Routes.signIn);
              await tester.pumpAndSettle();
              await tap(arabic ? 'تسجيل الدخول  →' : 'SIGN IN  →');
              expect(
                  find.text(arabic
                      ? 'أدخل بريدًا إلكترونيًا صحيحًا'
                      : 'Enter a valid email'),
                  findsOneWidget);
              expect(
                  find.text(arabic
                      ? 'كلمة المرور ٤ أحرف على الأقل'
                      : 'Password must be at least 4 characters'),
                  findsOneWidget);
              navigator.pop();
              await tester.pumpAndSettle();
              navigator.pushNamed(Routes.addresses);
              await tester.pumpAndSettle();
              await tap(arabic ? 'إضافة عنوان' : 'ADD ADDRESS');
              await tap(arabic ? 'حفظ العنوان' : 'SAVE ADDRESS');
              expect(find.text(arabic ? 'هذا الحقل مطلوب' : 'Required'),
                  findsWidgets);
              final before = await serviceLocator<GetAddresses>()();
              final fields = find.byType(TextFormField);
              final values = [
                'Office with a long address label',
                'Test User',
                '01000000000',
                'Cairo',
                'Centre',
                'Main Street',
                '12'
              ];
              for (var i = 0; i < values.length; i++) {
                await tester.ensureVisible(fields.at(i));
                await tester.pumpAndSettle();
                await tester.enterText(fields.at(i), values[i]);
              }
              tester.view.viewInsets = const FakeViewPadding(bottom: 250);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              await tap(arabic ? 'حفظ العنوان' : 'SAVE ADDRESS');
              tester.view.resetViewInsets();
              await tester.pumpAndSettle();
              final after = await serviceLocator<GetAddresses>()();
              expect(after.length, before.length + 1);
              expect(after.last.address.building, '12');
              expect(tester.takeException(), isNull);
              navigator.pop();
              await tester.pumpAndSettle();
              navigator.pushNamed(Routes.search,
                  arguments: const ProductSearchCriteria());
              await tester.pumpAndSettle();
              await tap(arabic ? 'التصفية' : 'FILTERS');
              await tap(arabic ? 'هوديز' : 'Hoodies');
              final search =
                  tester.element(find.byType(SearchPage)).read<SearchCubit>();
              expect(
                  (search.state as SearchReady).criteria.category, 'Hoodies');
              await tap(arabic ? 'الترتيب' : 'SORT');
              await tap(
                  arabic ? 'السعر: من الأعلى للأقل' : 'Price: high to low');
              expect((search.state as SearchReady).criteria.sort,
                  ProductSort.priceHighToLow);
              navigator.pop();
              await tester.pumpAndSettle();
              navigator.pushNamed(Routes.productDetails, arguments: 'nb-9060');
              await tester.pumpAndSettle();
              final writeReview =
                  find.text(arabic ? 'اكتب تقييمًا' : 'WRITE REVIEW');
              await tester.scrollUntilVisible(writeReview, 250,
                  scrollable: find
                      .byWidgetPredicate((widget) =>
                          widget is Scrollable &&
                          widget.axisDirection == AxisDirection.down)
                      .last);
              await tester.pumpAndSettle();
              await tap(arabic ? 'اكتب تقييمًا' : 'WRITE REVIEW');
              await tap(arabic ? 'أكبر من المعتاد' : 'Runs large');
              tester.view.viewInsets = const FakeViewPadding(bottom: 250);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              await tester.ensureVisible(find.byType(TextField).last);
              await tester.enterText(
                  find.byType(TextField).last, 'Great everyday comfort.');
              await tap(arabic ? 'إرسال التقييم' : 'SUBMIT REVIEW');
              tester.view.resetViewInsets();
              await tester.pumpAndSettle();
              expect(find.byType(ProductDetailsPage), findsOneWidget);
              navigator.pop();
              await tester.pumpAndSettle();
              navigator.pushNamed(Routes.orderDetails,
                  arguments: 'NOVA-025884');
              await tester.pumpAndSettle();
              final returnButton = find.text(arabic ? 'إرجاع' : 'RETURN');
              await tester.scrollUntilVisible(returnButton, 250,
                  scrollable: find
                      .byWidgetPredicate((widget) =>
                          widget is Scrollable &&
                          widget.axisDirection == AxisDirection.down)
                      .last);
              await tester.pumpAndSettle();
              await tap(arabic ? 'إرجاع' : 'RETURN');
              await tap(arabic ? 'تبديل المقاس' : 'EXCHANGE SIZE');
              await tap('43');
              expect(find.text(arabic ? 'مقاس غير مناسب' : 'Wrong size'),
                  findsOneWidget);
              expect(tester.takeException(), isNull);
            }));
  }
}
