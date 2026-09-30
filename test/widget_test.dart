import 'package:fashion_e_commerce/app/app.dart';
import 'package:fashion_e_commerce/core/config/app_constants.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/home_page.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/product_details_page.dart';
import 'package:fashion_e_commerce/features/splash/presentation/pages/brand_reveal_splash_page.dart';
import 'package:fashion_e_commerce/features/splash/presentation/pages/initial_splash_page.dart';
import 'package:fashion_e_commerce/features/splash/presentation/widgets/brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(configureDependencies);

  testWidgets('app starts on the initial splash page', (tester) async {
    await tester.pumpWidget(const FashionApp());
    await tester.pump();

    expect(find.byType(InitialSplashPage), findsOneWidget);
    expect(find.byType(BrandLogo), findsOneWidget);
    expect(find.byType(BrandRevealSplashPage), findsNothing);
  });

  testWidgets('initial splash navigates to brand reveal after the delay',
      (tester) async {
    await tester.pumpWidget(const FashionApp());
    await tester.pump();

    await tester.pump(AppConstants.initialSplashDuration);
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(BrandRevealSplashPage), findsOneWidget);
    expect(find.byType(BrandLogo), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('splash flow reaches the home catalog', (tester) async {
    await _reachHome(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('NOVA_'), findsOneWidget);
    expect(find.text('NEW ARRIVALS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('product card opens product details', (tester) async {
    await _reachHome(tester);

    await tester.drag(
      find.byType(ListView).first,
      const Offset(0, -520),
    );
    await tester.pumpAndSettle();

    expect(find.text('9060'), findsOneWidget);

    await tester.tap(find.text('9060'));
    await tester.pumpAndSettle();

    expect(find.byType(ProductDetailsPage), findsOneWidget);
    expect(find.text('SELECT SIZE'), findsOneWidget);
    expect(find.text('ADD TO BAG  →'), findsNothing);
    expect(find.text('SELECT A SIZE'), findsOneWidget);

    await tester.tap(find.text('42').first);
    await tester.pumpAndSettle();

    expect(find.text('ADD TO BAG  →'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposing initial splash cancels delayed navigation',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: InitialSplashPage()),
    );

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(AppConstants.initialSplashDuration);

    expect(tester.takeException(), isNull);
    expect(find.byType(BrandRevealSplashPage), findsNothing);
  });
}

Future<void> _reachHome(WidgetTester tester) async {
  await tester.pumpWidget(const FashionApp());
  await tester.pump();

  await tester.pump(AppConstants.initialSplashDuration);
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(AppConstants.brandRevealDuration);
  await tester.pumpAndSettle();
}
