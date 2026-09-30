import 'package:fashion_e_commerce/core/config/app_constants.dart';
import 'package:fashion_e_commerce/features/splash/presentation/widgets/brand_logo.dart';
import 'package:flutter/material.dart';

class SlidingBrandLogo extends StatefulWidget {
  const SlidingBrandLogo({super.key});

  @override
  State<SlidingBrandLogo> createState() => _SlidingBrandLogoState();
}

class _SlidingBrandLogoState extends State<SlidingBrandLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.logoSlideDuration,
    );
    _position = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.5),
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _position,
      child: const BrandLogo(),
    );
  }
}
