import 'support/network_images.dart';
import 'package:fashion_e_commerce/app/app.dart';
import 'package:fashion_e_commerce/core/config/app_constants.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/core/localization/locale_cubit.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:fashion_e_commerce/features/cart/presentation/pages/cart_page.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_product_details.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/home_page.dart';
import 'package:fashion_e_commerce/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:fashion_e_commerce/features/checkout/presentation/pages/checkout_page.dart';
import 'package:fashion_e_commerce/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:fashion_e_commerce/features/orders/domain/repositories/orders_repository.dart';
import 'package:fashion_e_commerce/features/orders/presentation/pages/order_details_page.dart';
import 'package:fashion_e_commerce/features/orders/presentation/pages/orders_page.dart';
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
        '${arabic ? 'Arabic small phone' : 'English'} purchase keeps coupon, address, order and clears bag',
        (tester) => withTestImages(() async {
              tester.view.physicalSize =
                  Size(arabic ? 320 : 390, arabic ? 640 : 844);
              tester.view.devicePixelRatio = 1;
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);
              await tester.pumpWidget(const FashionApp());
              await tester.pump();
              await tester.pump(AppConstants.initialSplashDuration);
              await tester.pump(const Duration(milliseconds: 250));
              await tester.pumpAndSettle();
              if (find.byType(OnboardingPage).evaluate().isNotEmpty) {
                await tester.tap(find.text('SKIP FOR NOW'));
                await tester.pumpAndSettle();
              }
              final home = tester.element(find.byType(HomePage));
              if (arabic) {
                home.read<LocaleCubit>().useArabic();
                await tester.pumpAndSettle();
              }
              final product =
                  await serviceLocator<GetProductDetails>()('nb-9060');
              await serviceLocator<CartRepository>().addItem(CartItem(
                  product: product, color: product.colors.first, size: '42'));
              Navigator.of(home).pushNamed(Routes.cart);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              if (arabic) {
                tester.view.viewInsets = const FakeViewPadding(bottom: 280);
                await tester.pumpAndSettle();
                expect(tester.takeException(), isNull);
                tester.view.resetViewInsets();
                await tester.pumpAndSettle();
              }
              await tester.enterText(find.byType(TextField), 'WRONG');
              await tester.tap(find.text(arabic ? 'تطبيق' : 'APPLY'));
              await tester.pumpAndSettle();
              expect(
                  find.text(arabic
                      ? 'كود الخصم غير صحيح.'
                      : 'Invalid promotion code.'),
                  findsOneWidget);
              await tester.enterText(find.byType(TextField), 'STREET10');
              await tester.tap(find.text(arabic ? 'تطبيق' : 'APPLY'));
              await tester.pumpAndSettle();
              expect(find.text('STREET10'), findsOneWidget);
              await tester
                  .tap(find.text(arabic ? 'إتمام الشراء  →' : 'CHECKOUT  →'));
              await tester.pumpAndSettle();
              final fields = arabic
                  ? [
                      'الاسم الكامل',
                      'رقم الهاتف',
                      'المدينة',
                      'المنطقة',
                      'الشارع',
                      'المبنى'
                    ]
                  : [
                      'FULL NAME',
                      'PHONE',
                      'CITY',
                      'AREA',
                      'STREET',
                      'BUILDING'
                    ];
              final values = [
                'Test Shopper',
                '01000000000',
                'Cairo',
                'Centre',
                'Main Street',
                '12'
              ];
              for (var i = 0; i < fields.length; i++) {
                final field = find.byKey(ValueKey<String>(fields[i]));
                await tester.scrollUntilVisible(field, 100,
                    scrollable: find.byType(Scrollable).last);
                await tester.enterText(field, values[i]);
              }
              final continueButton = find.text(
                  arabic ? 'متابعة إلى التوصيل  ←' : 'CONTINUE TO DELIVERY  →');
              await tester.scrollUntilVisible(continueButton, 100,
                  scrollable: find.byType(Scrollable).last);
              await tester.tap(continueButton);
              await tester.pumpAndSettle();
              expect(tester.testTextInput.isVisible, isFalse);
              await tester
                  .tap(find.text(arabic ? 'توصيل سريع' : 'EXPRESS DELIVERY'));
              await tester.pumpAndSettle();
              // Android/system back goes to the preceding step rather than leaving checkout.
              await tester.binding.handlePopRoute();
              await tester.pumpAndSettle();
              final cubit = tester
                  .element(find.byType(CheckoutPage))
                  .read<CheckoutCubit>();
              expect(
                  (cubit.state as CheckoutReady).step, CheckoutStep.delivery);
              await tester
                  .tap(find.text(arabic ? 'توصيل سريع' : 'EXPRESS DELIVERY'));
              await tester.pumpAndSettle();
              await tester.tap(find
                  .text(arabic ? 'الدفع عند الاستلام' : 'CASH ON DELIVERY'));
              await tester.pumpAndSettle();
              final review = cubit.state as CheckoutReady;
              expect(review.discount, product.price * .1);
              expect(review.total, product.price * .9 + 90);
              expect(
                  find.text(
                      'Test Shopper\n12, Main Street, Centre, Cairo\n01000000000'),
                  findsOneWidget);
              final place =
                  find.text(arabic ? 'تأكيد الطلب' : 'PLACE ORDER  →');
              await tester.scrollUntilVisible(place, 100,
                  scrollable: find.byType(Scrollable).last);
              await tester.tap(place);
              await tester.pumpAndSettle();
              final receipt = (cubit.state as CheckoutCompleted).receipt;
              expect(find.text('#${receipt.orderId}'), findsOneWidget);
              expect(
                  tester
                      .widget<Text>(find.text('#${receipt.orderId}'))
                      .textDirection,
                  TextDirection.ltr);
              expect(
                  tester
                      .widget<Icon>(find.byIcon(AppIcons.check))
                      .textDirection,
                  TextDirection.ltr);
              expect(tester.takeException(), isNull);
              final viewOrder =
                  find.text(arabic ? 'عرض الطلب' : 'VIEW ORDER  →');
              await tester.ensureVisible(viewOrder);
              await tester.tap(viewOrder);
              await tester.pumpAndSettle();
              expect(find.byType(OrderDetailsPage), findsOneWidget);
              expect(find.text(arabic ? 'تم تأكيد الطلب' : 'ORDER PLACED'),
                  findsWidgets);
              expect(tester.takeException(), isNull);
              final saved = await serviceLocator<OrdersRepository>()
                  .getOrderById(receipt.orderId);
              expect(saved.total, review.total);
              expect(saved.shippingAddressLabel, contains('12, Main Street'));
              await tester.binding.handlePopRoute();
              await tester.pumpAndSettle();
              expect(find.byType(HomePage), findsOneWidget);
              expect(find.byType(CartPage), findsNothing);
              Navigator.of(tester.element(find.byType(HomePage)))
                  .pushNamed(Routes.orders);
              await tester.pumpAndSettle();
              expect(find.byType(OrdersPage), findsOneWidget);
              expect(find.text('#${receipt.orderId}'), findsOneWidget);
              expect(tester.takeException(), isNull);
              await tester.binding.handlePopRoute();
              await tester.pumpAndSettle();
              Navigator.of(tester.element(find.byType(HomePage)))
                  .pushNamed(Routes.cart);
              await tester.pumpAndSettle();
              expect(find.text(arabic ? 'حقيبتك فارغة' : 'YOUR BAG IS EMPTY'),
                  findsOneWidget);
              expect(
                  await serviceLocator<CartRepository>().getItems(), isEmpty);
              expect(tester.takeException(), isNull);
            }));
  }
}
