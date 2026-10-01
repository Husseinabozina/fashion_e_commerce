// Firebase client configuration uses non-secret project/app identifiers.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS || TargetPlatform.macOS => ios,
      _ => throw UnsupportedError(
          'Firebase is configured for Android, Apple and Web.'),
    };
  }

  static const android = FirebaseOptions(
    apiKey: "AIzaSyAXQnCCIZkOW1kuCb1MPLmA2BYEQXCWe4M",
    appId: "1:1096287013355:android:2a03275ecb00666b5b71ae",
    messagingSenderId: "1096287013355",
    projectId: "nova-fashion-hussein",
    storageBucket: "nova-fashion-hussein.firebasestorage.app",
  );
  static const ios = FirebaseOptions(
    apiKey: "AIzaSyA-gIf08U6tyYmwgRobAgfK1vYWPM_xGbU",
    appId: "1:1096287013355:ios:f9f1fb05ae67b3d25b71ae",
    messagingSenderId: "1096287013355",
    projectId: "nova-fashion-hussein",
    storageBucket: "nova-fashion-hussein.firebasestorage.app",
    iosBundleId: "com.example.fashionECommerce",
  );
  static const web = FirebaseOptions(
    apiKey: "AIzaSyDmn76OY2Mom-ggIiTGSae8TQtERc_WX-w",
    appId: "1:1096287013355:web:ff7ea7d42e8e4cc95b71ae",
    messagingSenderId: "1096287013355",
    projectId: "nova-fashion-hussein",
    storageBucket: "nova-fashion-hussein.firebasestorage.app",
    authDomain: "nova-fashion-hussein.firebaseapp.com",
  );
}
