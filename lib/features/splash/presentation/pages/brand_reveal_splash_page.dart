import 'dart:async';

import 'package:fashion_e_commerce/core/config/app_constants.dart';
import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/splash/presentation/widgets/sliding_brand_logo.dart';
import 'package:flutter/material.dart';

class BrandRevealSplashPage extends StatefulWidget {
  const BrandRevealSplashPage({super.key});

  @override
  State<BrandRevealSplashPage> createState() => _BrandRevealSplashPageState();
}

class _BrandRevealSplashPageState extends State<BrandRevealSplashPage> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(AppConstants.brandRevealDuration, _goHome);
  }

  void _goHome() {
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.home,
      (route) => false,
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
