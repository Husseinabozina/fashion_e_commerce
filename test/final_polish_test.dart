import 'package:fashion_e_commerce/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:fashion_e_commerce/features/brands/domain/repositories/brands_repository.dart';
import 'package:fashion_e_commerce/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'support/network_images.dart';
import 'package:fashion_e_commerce/app/app.dart';
import 'package:fashion_e_commerce/core/config/app_constants.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/core/localization/locale_cubit.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/home_page.dart';
import 'package:fashion_e_commerce/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

final _issues = <String>[];
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
        '${arabic ? 'Arabic' : 'English'} screens fit 320px with enlarged text',
        (tester) => withTestImages(() async {
              tester.view.physicalSize = const Size(320, 640);
              tester.view.devicePixelRatio = 1;
              tester.platformDispatcher.textScaleFactorTestValue = 1.6;
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);
              addTearDown(
                  tester.platformDispatcher.clearTextScaleFactorTestValue);
              _issues.clear();
              await _home(tester);
              if (arabic) {
                tester
                    .element(find.byType(HomePage))
                    .read<LocaleCubit>()
                    .useArabic();
                await tester.pumpAndSettle();
              }
              _check(tester, 'Home');
              final heroButton = tester.getRect(find.ancestor(
                of: find.text(arabic ? 'تسوق المجموعة' : 'SHOP THE DROP'),
                matching:
                    find.byWidgetPredicate((widget) => widget is FilledButton),
              ));
              expect(heroButton.left, greaterThanOrEqualTo(0));
              expect(heroButton.right, lessThanOrEqualTo(320));
              await _scroll(tester, 'Home');
              final navigator =
                  Navigator.of(tester.element(find.byType(HomePage)));
              final routes = <(String, Object?)>[
                (Routes.shop, null),
                (Routes.discover, null),
                (Routes.search, const ProductSearchCriteria()),
                (Routes.productDetails, 'nb-9060'),
                (Routes.brand, 'NEW BALANCE'),
                (Routes.followingBrands, null),
                (Routes.wishlist, null),
                (Routes.account, null),
                (Routes.signIn, null),
                (Routes.addresses, null),
                (Routes.notifications, null),
                (Routes.orders, null),
                (Routes.orderDetails, 'NOVA-025884'),
                (Routes.cart, null),
              ];
              for (final (route, args) in routes) {
                navigator.pushNamed(route, arguments: args);
                await tester.pumpAndSettle();
                _check(tester, route);
                await _scroll(tester, route);
                navigator.pop();
                await tester.pumpAndSettle();
              }
              // Exercise filled states as well as the empty states above.
              final product = await serviceLocator<CatalogRepository>()
                  .getProductById('nb-9060');
              await tester
                  .element(find.byType(HomePage))
                  .read<WishlistCubit>()
                  .toggle(product);
              await serviceLocator<CartRepository>().addItem(
                  CartItem(product: product, color: 'Black', size: '44'));
              final brands = serviceLocator<BrandsRepository>();
              final brand = await brands.getBrandByName('NEW BALANCE');
              await brands.toggleFollow(brand.id);
              for (final route in [
                Routes.wishlist,
                Routes.followingBrands,
                Routes.cart,
                Routes.checkout
              ]) {
                navigator.pushNamed(route);
                await tester.pumpAndSettle();
                _check(tester, '$route filled');
                await _scroll(tester, '$route filled');
                navigator.pop();
                await tester.pumpAndSettle();
              }
              expect(_issues, isEmpty);
            }));
  }
}

void _check(WidgetTester tester, String screen) {
  final error = tester.takeException();
  if (error != null) _issues.add('$screen: $error');
}

Future<void> _scroll(WidgetTester tester, String screen) async {
  final scrollables = find.byType(Scrollable);
  for (final element in scrollables.evaluate().toList()) {
    final state = (element as StatefulElement).state as ScrollableState;
    if (state.position.maxScrollExtent == 0) continue;
    final extent = state.position.maxScrollExtent;
    for (double offset = 200; offset < extent; offset += 250) {
      state.position.jumpTo(offset);
      await tester.pumpAndSettle();
      _check(tester, '$screen scrolled');
    }
    state.position.jumpTo(state.position.maxScrollExtent);
    await tester.pumpAndSettle();
    _check(tester, '$screen scrolled');
  }
}

Future<void> _home(WidgetTester tester) async {
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
}
