import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class TextStyles {
  TextStyles._();

  static TextStyle get displayLarge => TextStyle(
    fontSize: 57.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    color: AppColors.text,
    height: 1.12,
  );

  static TextStyle get displayMedium => TextStyle(
    fontSize: 45.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: AppColors.text,
    height: 1.16,
  );

  static TextStyle get displaySmall => TextStyle(
    fontSize: 36.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: AppColors.text,
    height: 1.22,
  );

  static TextStyle get headlineLarge => TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.text,
    height: 1.25,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.text,
    height: 1.29,
  );

  static TextStyle get headlineSmall => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.text,
    height: 1.33,
  );

  static TextStyle get titleLarge => TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.text,
    height: 1.27,
  );

  static TextStyle get titleMedium => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: AppColors.text,
    height: 1.5,
  );

  static TextStyle get titleSmall => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.text,
    height: 1.43,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.text,
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.text,
    height: 1.43,
  );

  static TextStyle get bodySmall => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.text,
    height: 1.33,
  );

  static TextStyle get labelLarge => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.text,
    height: 1.43,
  );

  static TextStyle get labelMedium => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.text,
    height: 1.33,
  );

  static TextStyle get labelSmall => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.text,
    height: 1.45,
  );

  static TextStyle get caption => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
    height: 1.33,
  );

  static TextStyle get overline => TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: AppColors.textTertiary,
    height: 1.6,
  );

  static TextStyle get button => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.onPrimary,
    height: 1.43,
  );
}
