import 'package:fashion_e_commerce/app/app.dart';
import 'package:fashion_e_commerce/core/config/app_constants.dart';
import 'package:fashion_e_commerce/features/splash/presentation/pages/brand_reveal_splash_page.dart';
import 'package:fashion_e_commerce/features/splash/presentation/pages/initial_splash_page.dart';
import 'package:fashion_e_commerce/features/splash/presentation/widgets/brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts on the initial splash page', (tester) async {
    await tester.pumpWidget(const FashionApp());

    expect(find.byType(InitialSplashPage), findsOneWidget);
    expect(find.byType(BrandLogo), findsOneWidget);
    expect(find.byType(BrandRevealSplashPage), findsNothing);
  });

  testWidgets('initial splash navigates to brand reveal after the delay',
      (tester) async {
    await tester.pumpWidget(const FashionApp());

    await tester.pump(AppConstants.initialSplashDuration);
    await tester.pumpAndSettle();

    expect(find.byType(BrandRevealSplashPage), findsOneWidget);
    expect(find.byType(BrandLogo), findsOneWidget);
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
