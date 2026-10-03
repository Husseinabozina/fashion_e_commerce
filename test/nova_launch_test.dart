import 'dart:async';

import 'package:fashion_e_commerce/core/branding/nova_launch_view.dart';
import 'package:fashion_e_commerce/core/branding/nova_logo.dart';
import 'package:fashion_e_commerce/core/config/app_constants.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/entities/shopping_preferences.dart';
import 'package:fashion_e_commerce/features/splash/presentation/pages/initial_splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget launch(Future<ShoppingPreferences> Function() load,
        {bool reducedMotion = false}) =>
    MaterialApp(
      builder: (context, child) => MediaQuery(
          data:
              MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
          child: child!),
      home: InitialSplashPage(loadPreferences: load),
      routes: {
        Routes.home: (_) => const Scaffold(body: Text('HOME DESTINATION')),
        Routes.onboarding: (_) =>
            const Scaffold(body: Text('ONBOARDING DESTINATION')),
      },
    );

void main() {
  testWidgets('first launch reveals NOVA then removes splash from back stack',
      (tester) async {
    await tester
        .pumpWidget(launch(() async => const ShoppingPreferences.initial()));
    await tester.pump();
    expect(find.byType(BrandLogo), findsOneWidget);
    expect(find.text('ONBOARDING DESTINATION'), findsNothing);
    await tester.pump(AppConstants.initialSplashDuration);
    await tester.pumpAndSettle();
    expect(find.text('ONBOARDING DESTINATION'), findsOneWidget);
    expect(find.byType(InitialSplashPage), findsNothing);
    expect(
        Navigator.of(tester.element(find.text('ONBOARDING DESTINATION')))
            .canPop(),
        isFalse);
  });

  testWidgets(
      'returning customer reaches Home only after preferences are ready',
      (tester) async {
    final ready = Completer<ShoppingPreferences>();
    await tester.pumpWidget(launch(() => ready.future));
    await tester.pump();
    await tester.pump(AppConstants.initialSplashDuration);
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text('HOME DESTINATION'), findsNothing);
    expect(tester.widget<BrandLogo>(find.byType(BrandLogo)).progress, 1);
    expect(find.text('Preparing your edit…'), findsOneWidget);
    ready.complete(const ShoppingPreferences(hasCompletedOnboarding: true));
    await tester.pumpAndSettle();
    expect(find.text('HOME DESTINATION'), findsOneWidget);
  });

  testWidgets(
      'reduced motion shows final identity and skips the animation wait',
      (tester) async {
    final ready = Completer<ShoppingPreferences>();
    await tester.pumpWidget(launch(() => ready.future, reducedMotion: true));
    expect(tester.widget<BrandLogo>(find.byType(BrandLogo)).progress, 1);
    ready.complete(const ShoppingPreferences(hasCompletedOnboarding: true));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('HOME DESTINATION'), findsOneWidget);
  });

  testWidgets('preference failure can be retried without replaying the reveal',
      (tester) async {
    var attempts = 0;
    await tester.pumpWidget(launch(() async {
      attempts++;
      if (attempts == 1) throw StateError('offline');
      return const ShoppingPreferences.initial();
    }));
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('ONBOARDING DESTINATION'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposing before initialization completes never navigates',
      (tester) async {
    final ready = Completer<ShoppingPreferences>();
    await tester.pumpWidget(launch(() => ready.future));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const MaterialApp(home: Text('REPLACEMENT')));
    ready.complete(const ShoppingPreferences.initial());
    await tester.pumpAndSettle();
    expect(find.text('REPLACEMENT'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('brand and recovery fit small RTL and landscape displays',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final size in [const Size(320, 568), const Size(640, 320)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(MaterialApp(
          home: Directionality(
              textDirection: TextDirection.rtl,
              child: MediaQuery(
                  data: MediaQueryData(
                      size: size, textScaler: const TextScaler.linear(1.5)),
                  child: NovaLaunchView(
                      progress: 1,
                      footer: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('تعذر الاتصال. حاول مرة أخرى.'),
                        FilledButton(
                            onPressed: () {},
                            child: const Text('حاول مرة أخرى')),
                      ]))))));
      await tester.pump();
      expect(find.text('NOVA'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
