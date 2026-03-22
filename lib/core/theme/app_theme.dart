
import 'package:flutter/material.dart';
import 'package:casaly/core/theme/app_colors.dart';
import 'package:casaly/core/theme/app_typography.dart';
import 'package:casaly/core/theme/app_radius.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    // === THE WARM PAPER BASE ===
    scaffoldBackgroundColor: AppColors.surface,
    
    // === BOTANICAL ARCHIVIST COLOR SCHEME ===
    colorScheme: ColorScheme.light(
      // Primary - Deep Forest Green
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryContainer,
      onPrimary: AppColors.onPrimary,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      
      // Secondary - Sunset Orange  
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondary: AppColors.onSecondary,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      
      // Tertiary - Deep Berry
      tertiary: AppColors.tertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiary: AppColors.onTertiary,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      
      // Surface Hierarchy
      surface: AppColors.surface,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      
      // Surface Text
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      
      // Semantic
      error: AppColors.error,
      onError: AppColors.onTertiary,
    ),
    
    // === EDITORIAL TYPOGRAPHY ===
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLg.copyWith(color: AppColors.onSurface),
      displayMedium: AppTypography.displayMd.copyWith(color: AppColors.onSurface),
      headlineLarge: AppTypography.headlineLg.copyWith(color: AppColors.onSurface),
      headlineMedium: AppTypography.headlineMd.copyWith(color: AppColors.onSurface),
      headlineSmall: AppTypography.headlineSm.copyWith(color: AppColors.onSurface),
      titleLarge: AppTypography.titleLg.copyWith(color: AppColors.onSurface),
      titleMedium: AppTypography.titleMd.copyWith(color: AppColors.onSurface),
      bodyLarge: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
      bodyMedium: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
      bodySmall: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
      labelLarge: AppTypography.labelLg.copyWith(color: AppColors.onSurface),
      labelMedium: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
      labelSmall: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
    ),
    
    // === COMPONENT THEMES ===
    // Cards - 2rem radius, tonal layering
    cardTheme: CardThemeData(
      elevation: 0, // No shadows, use tonal layering
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      color: AppColors.surfaceContainerLowest,
      margin: const EdgeInsets.all(0), // Control spacing externally
    ),
    
    // Buttons - Pill-shaped, premium feel
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: AppTypography.labelLg,
      ),
    ),
    
    // Input Fields - Warm filled style
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.all(16),
      labelStyle: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
      hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
    ),
    
    // App Bar - Clean, editorial
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      titleTextStyle: AppTypography.headlineMd,
      centerTitle: false,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.onSurface,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryContainer,
      secondary: AppColors.secondaryContainer,
      surface: AppColors.onSurface,
      error: AppColors.error,
      onPrimary: AppColors.onPrimaryContainer,
      onSecondary: AppColors.onSecondaryContainer,
      onSurface: AppColors.surface,
      onError: AppColors.onTertiary,
    ),
  );
}
