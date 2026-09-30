import 'package:fashion_e_commerce/core/config/app_constants.dart';
import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/features/splash/presentation/widgets/sliding_brand_logo.dart';
import 'package:flutter/material.dart';

class BrandRevealSplashPage extends StatelessWidget {
  const BrandRevealSplashPage({super.key});

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
