import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/sandbox_payment.dart';
import 'package:fashion_e_commerce/features/checkout/domain/services/sandbox_payments.dart';
import 'package:fashion_e_commerce/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:fashion_e_commerce/features/checkout/presentation/pages/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'checkout_sandbox_flow_test.dart' show FakePayments;
import 'sandbox_payments_test.dart' show request;
import 'support/network_images.dart';

void main() {
  setUp(() async {
    await serviceLocator.reset();
    configureDependencies();
  });
  tearDown(() => serviceLocator.reset());
  for (final ar in [false, true]) {
    testWidgets(
        '${ar ? 'Arabic small phone' : 'English'} sandbox checkout verifies before confirmation',
        (tester) => withTestImages(() async {
              tester.view.physicalSize = Size(ar ? 320 : 1000, ar ? 640 : 800);
              tester.view.devicePixelRatio = 1;
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);
              final payment = FakePayments();
              await serviceLocator.unregister<SandboxPayments>();
              serviceLocator.registerSingleton<SandboxPayments>(payment);
              final order = await request();
              await serviceLocator<CartRepository>()
                  .addItem(order.items.single);
              final cubit = serviceLocator<CheckoutCubit>();
              addTearDown(cubit.close);
              await cubit.load();
              cubit.saveAddress(order.address);
              cubit.selectDelivery(order.delivery);
              cubit.selectPayment(order.payment);
              await cubit.submitOrder();
              final locale = Locale(ar ? 'ar' : 'en');
              await tester.pumpWidget(BlocProvider.value(
                  value: cubit,
                  child: MaterialApp(
                    locale: locale,
                    supportedLocales: const [Locale('en'), Locale('ar')],
                    localizationsDelegates:
                        GlobalMaterialLocalizations.delegates,
                    theme: AppTheme.lightThemeFor(locale),
                    home: const CheckoutPage(),
                  )));
              await tester.pumpAndSettle();
              expect(
                  find.text(ar
                      ? 'مبلغ الاختبار: 1 د.ك — من غير خصم فلوس حقيقية.'
                      : 'Test amount: 1 KWD — no real money is charged.'),
                  findsOneWidget);
              final check = find.byKey(const Key('check-sandbox-payment'));
              await tester.scrollUntilVisible(check, 100,
                  scrollable: find.byType(Scrollable).last);
              await tester.tap(check);
              await tester.pumpAndSettle();
              expect(
                  find.textContaining(
                      ar ? 'الدفع لم يكتمل' : 'Payment is not complete'),
                  findsOneWidget);
              expect(await serviceLocator<CartRepository>().getItems(),
                  isNotEmpty);
              payment.offline = true;
              await tester.tap(check);
              await tester.pumpAndSettle();
              expect(
                  find.textContaining(
                      ar ? 'تعذر التحقق' : 'Could not verify payment'),
                  findsOneWidget);
              payment.offline = false;
              payment.status = SandboxPaymentStatus.paid;
              await tester.tap(check);
              await tester.pumpAndSettle();
              expect(
                  find.text(ar
                      ? 'تم التحقق من دفع تجريبي: 1 د.ك'
                      : 'Sandbox payment verified: 1 KWD'),
                  findsOneWidget);
              expect(
                  await serviceLocator<CartRepository>().getItems(), isEmpty);
              expect(tester.takeException(), isNull);
            }));
  }
}
