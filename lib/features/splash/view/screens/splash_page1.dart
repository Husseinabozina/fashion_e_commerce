import 'package:fashion_e_commerce/core/config/app_images.dart';
import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/features/splash/view/screens/splash_page2.dart';
import 'package:fashion_e_commerce/features/splash/view/widgets/logo_widget.dart';
import 'package:fashion_e_commerce/features/splash/view/widgets/sliding_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashPage1 extends StatefulWidget {
  const SplashPage1({super.key});

  @override
  State<SplashPage1> createState() => _SplashPage1State();
}

class _SplashPage1State extends State<SplashPage1> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return const SplashPage2();
      }));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.colorPrimary,
      body: Hero(
        tag: 'logo',
        child: Center(
          child: LogoWidget(),
        ),
      ),
    );
  }
}
