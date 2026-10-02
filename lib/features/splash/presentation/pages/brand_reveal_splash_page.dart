import 'package:fashion_e_commerce/core/presentation/retry_panel.dart';
import 'dart:async';

import 'package:fashion_e_commerce/core/config/app_constants.dart';
import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/usecases/get_shopping_preferences.dart';
import 'package:fashion_e_commerce/features/splash/presentation/widgets/sliding_brand_logo.dart';
import 'package:flutter/material.dart';

class BrandRevealSplashPage extends StatefulWidget {
  const BrandRevealSplashPage({super.key});

  @override
  State<BrandRevealSplashPage> createState() => _BrandRevealSplashPageState();
}

class _BrandRevealSplashPageState extends State<BrandRevealSplashPage> {
  Timer? _navigationTimer;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(
      AppConstants.brandRevealDuration,
      () => _goNext(),
    );
  }

  Future<void> _goNext() async {
    try {
      final preferences = await serviceLocator<GetShoppingPreferences>()();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        preferences.hasCompletedOnboarding ? Routes.home : Routes.onboarding,
        (route) => false,
      );
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return Scaffold(body: RetryPanel(onRetry: _goNext));
    return const Scaffold(
      backgroundColor: AppTheme.colorSecondary,
      body: Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Hero(
          tag: AppConstants.logoHeroTag,
          child: Center(
            child: SlidingBrandLogo(),
          ),
        ),
      ),
    );
  }
}
