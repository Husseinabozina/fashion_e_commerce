import 'package:fashion_e_commerce/core/config/app_images.dart';
import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          child: Center(
            child: Image.asset(AppImages.logo),
          ),
        ),
        const SizedBox(width: 10),
        Image.asset(AppImages.logoName),
      ],
    );
  }
}
