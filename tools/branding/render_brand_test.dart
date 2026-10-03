// Run with: flutter test --no-pub tools/branding/render_brand_test.dart
// Renders the actual production widget, including its bundled brand font.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:fashion_e_commerce/core/branding/nova_launch_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('export actual NOVA reveal frames', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final font = FontLoader('NovaDisplay')
      ..addFont(rootBundle.load('assets/fonts/Syne-Variable.ttf'));
    await font.load();
    final boundaryKey = GlobalKey();
    final folder = Directory('build/branding/frames')
      ..createSync(recursive: true);
    for (var frame = 0; frame < 65; frame++) {
      final progress = (frame / 48).clamp(0.0, 1.0);
      await tester.pumpWidget(RepaintBoundary(
          key: boundaryKey,
          child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: NovaLaunchView(progress: progress))));
      await tester.pump();
      final boundary = boundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('${folder.path}/frame-${frame.toString().padLeft(3, '0')}.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
    expect(tester.takeException(), isNull);
  });
}
