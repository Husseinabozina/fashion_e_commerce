import 'package:fashion_e_commerce/app/app.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/core/firebase/firebase_bootstrap.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (const bool.fromEnvironment('USE_DEMO_DATA')) {
    configureDependencies();
    runApp(const FashionApp());
  } else {
    runApp(const FirebaseBootstrap());
  }
}
