import 'package:fashion_e_commerce/core/config/app_images.dart';
import 'package:fashion_e_commerce/features/splash/view/widgets/logo_widget.dart';
import 'package:flutter/material.dart';

class SlidingWidget extends StatelessWidget {
  const SlidingWidget({
    Key? key,
    required this.slidingAnimation,
  }) : super(key: key);

  final Animation<Offset> slidingAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: slidingAnimation,
        builder: (context, _) {
          return SlideTransition(
            position: slidingAnimation,
            child: const LogoWidget(),
          );
        });
  }
}
