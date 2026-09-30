import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/splash/presentation/pages/brand_reveal_splash_page.dart';
import 'package:fashion_e_commerce/features/splash/presentation/pages/initial_splash_page.dart';
import 'package:flutter/material.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      Routes.initialSplash => _page(const InitialSplashPage(), settings),
      Routes.brandRevealSplash =>
        _page(const BrandRevealSplashPage(), settings),
      _ => _unknownRoute(settings),
    };
  }

  static MaterialPageRoute<dynamic> _page(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }

  static MaterialPageRoute<dynamic> _unknownRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => Scaffold(
        body: Center(
          child: Text('Unknown route: ${settings.name}'),
        ),
      ),
    );
  }
}
