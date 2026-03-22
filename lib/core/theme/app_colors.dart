
import 'package:flutter/material.dart';

abstract class AppColors {
  // === THE BOTANICAL ARCHIVIST PALETTE ===
  // Editorial-inspired design system with warm paper surfaces
  
  // === PRIMARY — Deep Forest Green ===
  static const primary = Color(0xFF245030);  // Deep forest green for brand and primary actions
  static const primaryContainer = Color(0xFFBDEFC3);  // Light green container
  static const primaryFixed = Color(0xFFBDEFC3);  // Success states, "completed" chips
  static const primaryFixedDim = Color(0xFFA2D2A8);  // Dimmed success state
  static const onPrimary = Color(0xFFFFFFFF);  // White text on primary
  static const onPrimaryContainer = Color(0xFF234F30);  // Dark green text on light green
  static const onPrimaryFixed = Color(0xFF234F30);  // Main heading text
  static const onPrimaryFixedVariant = Color(0xFF234F30);  // Primary text color

  // === SECONDARY — Sunset Orange ===
  static const secondary = Color(0xFFE8884A);  // Warm orange for active/urgent states
  static const secondaryContainer = Color(0xFFFFDBC9);  // Light orange container
  static const secondaryFixed = Color(0xFFFFDBC9);  // Task chips background
  static const secondaryFixedDim = Color(0xFF96490D);  // Active house tasks
  static const onSecondary = Color(0xFFFFFFFF);  // White text on orange
  static const onSecondaryContainer = Color(0xFF96490D);  // Dark orange text

  // === TERTIARY — Deep Berry ===
  static const tertiary = Color(0xFFD04848);  // Alert red for high-priority warnings
  static const tertiaryContainer = Color(0xFFFFDADA);  // Light red container
  static const onTertiary = Color(0xFFFFFFFF);  // White text on red
  static const onTertiaryContainer = Color(0xFF69000D);  // Very dark red for alerts

  // === SURFACE HIERARCHY — The "Warm Paper" System ===
  // Base Layer
  static const surface = Color(0xFFFFF8F4);  // Warm paper base of the app
  
  // Sectioning Layers (No-Line Rule - use these for boundaries)
  static const surfaceContainerLowest = Color(0xFFFFFFFF);  // Pure white for highlighted cards
  static const surfaceContainerLow = Color(0xFFF9F2EE);  // Large structural blocks
  static const surfaceContainer = Color(0xFFF3EDE9);  // Mid-level grouping
  static const surfaceContainerHigh = Color(0xFFEEE7E3);  // Input fields, close elements
  static const surfaceContainerHighest = Color(0xFFE8E1DD);  // Most interactive elements

  // Surface Text Colors
  static const onSurface = Color(0xFF1D1B19);  // Main text on surfaces
  static const onSurfaceVariant = Color(0xFF4F4539);  // Secondary text
  static const outline = Color(0xFF80736A);  // Subtle outlines
  static const outlineVariant = Color(0xFFC1C9BF);  // Ghost borders at 20% opacity

  // === SEMANTIC MAPPINGS ===
  static const success = primaryFixed;  // Completed tasks, "all clear" status
  static const warning = secondaryFixed;  // Attention needed
  static const error = tertiary;  // High-priority warnings
  static const info = secondary;  // General information

  // === LEGACY SUPPORT (for gradual migration) ===
  // Primary/Green colors
  static const green400 = primary;
  static const green50 = primaryContainer;
  static const green200 = primaryFixedDim;
  static const green600 = onPrimaryContainer;
  static const green800 = onPrimaryFixedVariant;
  
  // Secondary/Orange colors
  static const orange400 = secondary;
  static const orange50 = secondaryContainer;
  static const orange100 = secondaryFixed;
  static const orange200 = Color(0xFFFFB085); // Intermediate orange
  static const orange600 = onSecondaryContainer;
  static const orange800 = onSecondaryContainer;
  
  // Berry colors
  static const berry400 = tertiary;
  static const berry600 = onTertiaryContainer;
  
  // Cyan colors (migrate to secondary/primary)
  static const cyan400 = secondary;
  static const cyan600 = onSecondaryContainer;
  static const cyan800 = onPrimaryContainer;
  
  // Cream/Surface colors
  static const cream50 = surface;
  static const cream100 = surfaceContainerLow;
  static const cream200 = outlineVariant;
  static const cream300 = Color(0xFFD0C4B0); // Light borders
  static const cream400 = outline;
  static const cream600 = onSurfaceVariant;
  static const cream800 = onSurface;
}
