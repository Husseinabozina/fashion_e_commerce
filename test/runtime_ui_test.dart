import 'package:fashion_e_commerce/app/app.dart';
import 'package:fashion_e_commerce/core/config/app_constants.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/core/localization/locale_cubit.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/cart/presentation/pages/cart_page.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/product_details_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/search_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/home_page.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/product_details_page.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/search_page.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/shop_page.dart';
import 'package:fashion_e_commerce/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(configureDependencies);

  testWidgets('Shop the Drop opens newest products without the keyboard',
      (tester) async {
    await _reachHome(tester);
    await tester.tap(find.text('SHOP THE DROP'));
    await tester.pumpAndSettle();

    _expectNewestSearch(tester);
    expect(tester.testTextInput.isVisible, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('New Arrivals View opens the newest product list',
      (tester) async {
    await _reachHome(tester);
    await tester.scrollUntilVisible(find.text('NEW ARRIVALS'), 250,
        scrollable: find.byType(Scrollable).first);
    final arrivalsRow = find
        .ancestor(of: find.text('NEW ARRIVALS'), matching: find.byType(Row))
        .first;
    await tester
        .tap(find.descendant(of: arrivalsRow, matching: find.text('VIEW')));
    await tester.pumpAndSettle();

    _expectNewestSearch(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('category View opens Shop and direct search focuses input',
      (tester) async {
    await _reachHome(tester);
    await tester.scrollUntilVisible(find.text('SHOP BY CATEGORY'), 250,
        scrollable: find.byType(Scrollable).first);
    final categoryRow = find
        .ancestor(of: find.text('SHOP BY CATEGORY'), matching: find.byType(Row))
        .first;
    final categoryView =
        find.descendant(of: categoryRow, matching: find.text('VIEW'));
    await tester.tap(categoryView);
    await tester.pumpAndSettle();
    expect(find.byType(ShopPage), findsOneWidget);

    await tester.tap(find.byIcon(AppIcons.search).first);
    await tester.pumpAndSettle();
    expect(find.byType(SearchPage), findsOneWidget);
    expect(tester.testTextInput.isVisible, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('action labels meet readable contrast on light backgrounds',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Column(children: [
          TextButton(onPressed: () {}, child: const Text('View')),
          OutlinedButton(onPressed: () {}, child: const Text('Filter')),
          FilledButton(onPressed: () {}, child: const Text('Shop')),
          const Text('Description', style: TextStyle(color: AppColors.midGray)),
        ]),
      ),
    ));
    await tester.pumpAndSettle();

    for (final label in ['View', 'Filter', 'Shop', 'Description']) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
      final foreground = paragraph.text.style!.color!;
      final background =
          label == 'Shop' ? AppColors.acidLime : AppColors.offWhite;
      final a = foreground.computeLuminance();
      final b = background.computeLuminance();
      final contrast =
          a > b ? (a + 0.05) / (b + 0.05) : (b + 0.05) / (a + 0.05);
      expect(contrast, greaterThanOrEqualTo(4.5), reason: '$label contrast');
    }
  });

  testWidgets('Arabic Home fits a small phone and back arrow follows RTL',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _reachHome(tester);
    tester.element(find.byType(HomePage)).read<LocaleCubit>().useArabic();
    await tester.pumpAndSettle();
    expect(Directionality.of(tester.element(find.byType(HomePage))),
        TextDirection.rtl);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('تسوق المجموعة'));
    await tester.pumpAndSettle();
    final back = find.descendant(
      of: find.byType(BackButton),
      matching: find.byIcon(AppIcons.arrowLeft),
    );
    expect(back, findsOneWidget);
    expect(tester.widget<Icon>(back).icon!.matchTextDirection, isTrue);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اكتشف'));
    await tester.pumpAndSettle();
    final title = tester.renderObject<RenderParagraph>(find.text('اكتشف'));
    final contrast = (title.text.style!.color!.computeLuminance() + 0.05) /
        (AppColors.nearBlack.computeLuminance() + 0.05);
    expect(contrast, greaterThanOrEqualTo(4.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('look selection has a labeled touch target and updates the total',
      (tester) async {
    await _reachHome(tester);
    Navigator.of(tester.element(find.byType(HomePage))).pushNamed(
      Routes.productDetails,
      arguments: 'nb-9060',
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(ProductDetailsPage));
    final cubit = context.read<ProductDetailsCubit>();
    final before = cubit.state as ProductDetailsReady;
    final product = before.lookProducts.first;
    final selection = find.byWidgetPredicate((widget) =>
        widget is Semantics &&
        widget.properties.label == product.name &&
        widget.properties.checked != null);
    await tester.scrollUntilVisible(selection, 250,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    expect(tester.getSize(selection).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(selection).height, greaterThanOrEqualTo(48));
    expect(tester.widget<Semantics>(selection).properties.enabled, isTrue);
    // The edge outside the visible 24px box must still toggle the piece.
    await tester.tapAt(tester.getTopLeft(selection) + const Offset(3, 3));
    await tester.pumpAndSettle();
    final after = cubit.state as ProductDetailsReady;
    expect(after.selectedLookIds.contains(product.id), isFalse);
    expect(after.lookTotal, before.lookTotal - product.price);
    expect(tester.takeException(), isNull);
  });

  testWidgets('View Bag stays usable after closing the product page',
      (tester) async {
    await _reachHome(tester);
    final navigator = Navigator.of(tester.element(find.byType(HomePage)));
    navigator.pushNamed(Routes.productDetails, arguments: 'nb-9060');
    await tester.pumpAndSettle();
    tester
        .element(find.byType(ProductDetailsPage))
        .read<ProductDetailsCubit>()
        .selectSize('42');
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD TO BAG  →'));
    await tester.pumpAndSettle();
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailsPage), findsNothing);
    await tester.tap(find.text('VIEW BAG'));
    await tester.pumpAndSettle();
    expect(find.byType(CartPage), findsOneWidget);
    expect(find.text('9060'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _expectNewestSearch(WidgetTester tester) {
  expect(find.byType(SearchPage), findsOneWidget);
  final state = tester
      .element(find.byType(SearchPage))
      .read<SearchCubit>()
      .state as SearchReady;
  expect(state.criteria.sort, ProductSort.newest);
  expect(state.products, isNotEmpty);
  expect(state.products.first.isNew, isTrue);
}

Future<void> _reachHome(WidgetTester tester) async {
  await tester.pumpWidget(const FashionApp());
  await tester.pump();
  await tester.pump(AppConstants.initialSplashDuration);
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pumpAndSettle();
  if (find.byType(OnboardingPage).evaluate().isNotEmpty) {
    await tester.tap(find.text('SKIP FOR NOW'));
    await tester.pumpAndSettle();
  }
  expect(find.byType(HomePage), findsOneWidget);
}
