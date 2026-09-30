import 'package:fashion_e_commerce/app/app.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:flutter/material.dart';

void main() {
  configureDependencies();
  runApp(const FashionApp());
}
