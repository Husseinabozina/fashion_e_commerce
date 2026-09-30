import 'package:fashion_e_commerce/core/config/app_constants.dart';
import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/features/splash/presentation/widgets/sliding_brand_logo.dart';
import 'package:flutter/material.dart';

class BrandRevealSplashPage extends StatefulWidget {
  const BrandRevealSplashPage({super.key});

  @override
  State<BrandRevealSplashPage> createState() => _BrandRevealSplashPageState();
}

class _BrandRevealSplashPageState extends State<BrandRevealSplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Offset> _slidingAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.logoSlideDuration,
    );
    _slidingAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.5),
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorSecondary,
      body: const Padding(
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
