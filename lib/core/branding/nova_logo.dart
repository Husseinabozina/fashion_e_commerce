import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fashion_e_commerce/core/branding/nova_geometry.dart';
import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:flutter/material.dart';

/// The same folded ribbon geometry is exported to the native launcher assets.
class NovaMark extends StatelessWidget {
  const NovaMark(
      {super.key,
      this.size = 112,
      this.progress = 1,
      this.color = AppColors.acidLime});
  final double size;
  final double progress;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _NovaMarkPainter(progress, color)));
}

class NovaWordmark extends StatelessWidget {
  const NovaWordmark(
      {super.key, this.fontSize = 42, this.color = AppColors.offWhite});
  final double fontSize;
  final Color color;
  @override
  Widget build(BuildContext context) => Text('NOVA',
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
      style: TextStyle(
          fontFamily: 'NovaDisplay',
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          fontVariations: const [ui.FontVariation('wght', 800)],
          letterSpacing: -1.2,
          height: 1,
          color: color));
}

/// Progress 0 aligns with the native launch mark. Progress 1 is the full lockup.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.progress = 1});
  final double progress;
  @override
  Widget build(BuildContext context) {
    final lift = _phase(progress, .2, .78);
    final lettering = _phase(progress, .40, .86);
    final caption = _phase(progress, .65, 1);
    return Semantics(
      label: 'NOVA',
      image: true,
      child: ExcludeSemantics(
          child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(alignment: Alignment.center, children: [
                Transform.translate(
                    offset: Offset(0, -48 * lift),
                    child:
                        RepaintBoundary(child: NovaMark(progress: progress))),
                Transform.translate(
                    offset: Offset(0, 47 + 12 * (1 - lettering)),
                    child: Opacity(
                        opacity: lettering, child: const NovaWordmark())),
                Transform.translate(
                    offset: Offset(0, 90 + 6 * (1 - caption)),
                    child: Opacity(
                        opacity: caption,
                        child: const Text('STYLE IN MOTION',
                            textDirection: TextDirection.ltr,
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                                fontFamily: 'NovaDisplay',
                                fontVariations: const [
                                  ui.FontVariation('wght', 500)
                                ],
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 3.1,
                                color: AppColors.concrete)))),
              ]))),
    );
  }
}

double _phase(double value, double start, double end) => Curves.easeInOutCubic
    .transform(((value - start) / (end - start)).clamp(0.0, 1.0));

class _NovaMarkPainter extends CustomPainter {
  const _NovaMarkPainter(this.progress, this.color);
  final double progress;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final opening = math.sin(math.pi * _phase(progress, 0, .55)) * 3;
    final paint = Paint()..color = color;
    canvas.save();
    canvas.translate(-opening, opening);
    canvas.drawPath(NovaGeometry.leftFold(), paint);
    canvas.restore();
    canvas.save();
    canvas.translate(opening, -opening);
    canvas.drawPath(NovaGeometry.rightFold(), paint);
    canvas.restore();
    final diagonal = NovaGeometry.diagonal();
    canvas.drawPath(diagonal, paint);
    // A single restrained light pass follows the folded seam; it never loops.
    if (progress > .08 && progress < .6) {
      final sweep = (progress - .08) / .52;
      final x = -60 + 220 * sweep;
      canvas.save();
      canvas.clipPath(diagonal);
      canvas.drawRect(
          const Rect.fromLTWH(0, 0, 100, 100),
          Paint()
            ..shader =
                ui.Gradient.linear(Offset(x - 22, 0), Offset(x + 22, 100), [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: .28),
              Colors.white.withValues(alpha: 0)
            ], [
              0,
              .5,
              1
            ]));
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_NovaMarkPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
