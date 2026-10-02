import 'dart:async';

import 'package:fashion_e_commerce/core/config/app_constants.dart';
import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/splash/presentation/widgets/brand_logo.dart';
import 'package:flutter/material.dart';

class InitialSplashPage extends StatefulWidget {
  const InitialSplashPage({super.key});

  @override
  State<InitialSplashPage> createState() => _InitialSplashPageState();
}

class _InitialSplashPageState extends State<InitialSplashPage> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(AppConstants.initialSplashDuration, _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushNamed(Routes.brandRevealSplash);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.colorPrimary,
      body: Hero(
        tag: AppConstants.logoHeroTag,
        child: Center(
          child: BrandLogo(),
        ),
      ),
    );
  }
}
