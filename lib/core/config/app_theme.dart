import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static const Color colorPrimary = Color(0xFFDD8560);
  static const Color colorSecondary = Color(0xFF4D4D4D);

  static ThemeData get lightTheme {
    return ThemeData(
      textTheme: GoogleFonts.montserratTextTheme(),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
  }
}
