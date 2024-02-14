import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static TextStyle? heading1TextStyle({Color color = AppTheme.colorText7}) =>
      mainTextStyle(
          color: color, fontSize: font36.sp, fontWeight: fontWeightBold);
  static TextStyle? heading2TextStyle({Color color = AppTheme.colorText1}) =>
      mainTextStyle(
          color: color, fontSize: font24.sp, fontWeight: fontWeightBold);
  static TextStyle? heading3TextStyle({Color color = AppTheme.colorText1}) =>
      mainTextStyle(
          color: color, fontSize: font20.sp, fontWeight: fontWeightBold);
  static TextStyle? font16TextStyle({Color color = AppTheme.colorText1}) =>
      mainTextStyle(
          color: color, fontSize: font20.sp, fontWeight: fontWeightBold);
  static TextStyle? font14TextStyle({Color color = AppTheme.colorText1}) =>
      mainTextStyle(
          color: color, fontSize: font20.sp, fontWeight: fontWeightBold);
  static TextStyle? mainTextStyle(
          {Color? color, double? fontSize, FontWeight? fontWeight}) =>
      TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight);

  //font
  static const double font36 = 36;
  static const double font24 = 24;
  static const double font20 = 20;
  static const double font18 = 18;
  static const double font17 = 14;
  static const double font16 = 12;
  static const double font15 = 15;
  static const double font14 = 14;
  static const double font13 = 9;
  static const double font12 = 12;
  //app color
  static const Color colorPrimary = Color(0xFFDD8560);
  static const Color colorSecondary = Color(0xFF4D4D4D);
  static const Color colorText1 = Colors.black;
  static const Color colorText2 = Color(0xFFA1A8B0);
  static const Color colorText3 = Color(0xFF858585);
  static const Color colorText4 = Color(0xFF717784);
  static const Color colorText5 = Color(0xFF727272);
  static const Color colorText6 = Color(0xFF3B4453);

  static const Color colorText7 = Colors.white;

  //fontWeight
  static const fontWeightLight = FontWeight.w300;
  static const fontWeightnomral = FontWeight.w400;
  static const fontWeightMedium = FontWeight.w500;
  static const fontWeightSemiBold = FontWeight.w600;
  static const fontWeightBold = FontWeight.w700;
  static const fontWeightExtraBold = FontWeight.w800;
  static const fontWeightBlack = FontWeight.w900;
}
