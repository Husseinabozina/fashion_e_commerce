import 'package:fashion_e_commerce/core/config/app_images.dart';
import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/features/splash/view/widgets/sliding_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashPage2 extends StatefulWidget {
  const SplashPage2({super.key});

  @override
  State<SplashPage2> createState() => _SplashPage2State();
}

class _SplashPage2State extends State<SplashPage2>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> slidingAnimation;

  void initSlidingAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    slidingAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -.5))
            .animate(animationController);

    animationController.forward();
  }

  @override
  void initState() {
    initSlidingAnimation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorSecondary,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Hero(
          tag: 'logo',
          child: Center(
            child: SlidingWidget(slidingAnimation: slidingAnimation),
          ),
        ),
      ),
    );
  }
}
