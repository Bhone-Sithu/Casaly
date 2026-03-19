
import 'package:flutter/material.dart';
import 'package:casaly/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.info,
      surface: Colors.white,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.cream800,
      onError: Colors.white,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.cream800,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.info,
      surface: AppColors.cream800,
      error: AppColors.error,
      onPrimary: AppColors.cream800,
      onSecondary: AppColors.cream800,
      onSurface: AppColors.cream50,
      onError: AppColors.cream800,
    ),
  );
}
