import 'package:fashion_e_commerce/core/branding/nova_logo.dart';
import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NovaLaunchView extends StatelessWidget {
  const NovaLaunchView({super.key, this.progress = 0, this.footer});
  final double progress;
  final Widget? footer;
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.nearBlack,
          systemNavigationBarIconBrightness: Brightness.light),
      child: Scaffold(
          backgroundColor: AppColors.nearBlack,
          body: Column(children: [
            Expanded(
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: BrandLogo(progress: progress))))),
            if (footer != null)
              SafeArea(
                  top: false,
                  child: Padding(
                      padding: const EdgeInsets.all(24), child: footer!)),
          ])));
}
