import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTypography {
  // === THE EDITORIAL VOICE ===
  // High-contrast pairing: Noto Serif for display, Plus Jakarta Sans for functional

  // === DISPLAY VOICE — Noto Serif ===
  // Used for "Hero" moments - authoritative and slightly oversized
  static final displayLg = GoogleFonts.notoSerif(
    fontSize: 56, // 3.5rem
    fontWeight: FontWeight.w600,
    letterSpacing: -0.02 * 56, // -0.02em
    height: 1.1,
  );

  static final displayMd = GoogleFonts.notoSerif(
    fontSize: 30, // ~2.8rem
    fontWeight: FontWeight.w600,
    letterSpacing: -0.015 * 45,
    height: 1.15,
  );

  // === HEADLINE VOICE — Noto Serif ===
  // Section headers, card titles
  static final headlineLg = GoogleFonts.notoSerif(
    fontSize: 32, // 2rem
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01 * 32,
    height: 1.25,
  );

  static final headlineMd = GoogleFonts.notoSerif(
    fontSize: 28, // 1.75rem
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01 * 28, // -0.01em
    height: 1.3,
  );

  static final headlineSm = GoogleFonts.notoSerif(
    fontSize: 20, // 1.5rem
    fontWeight: FontWeight.w600,
    letterSpacing: -0.005 * 24,
    height: 1.35,
  );

  // === TITLE VOICE — Plus Jakarta Sans ===
  // Sub-headers, secondary navigation
  static final titleLg = GoogleFonts.plusJakartaSans(
    fontSize: 22, // 1.375rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static final titleMd = GoogleFonts.plusJakartaSans(
    fontSize: 18, // ~1.125rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  // === FUNCTIONAL VOICE — Plus Jakarta Sans ===
  // Standard reading text - medium weights for warm paper background
  static final bodyLg = GoogleFonts.plusJakartaSans(
    fontSize: 16, // 1rem
    fontWeight: FontWeight.w500, // Medium for warm background
    letterSpacing: 0.01 * 16, // +0.01em
    height: 1.5,
  );

  static final bodyMd = GoogleFonts.plusJakartaSans(
    fontSize: 14, // 0.875rem
    fontWeight: FontWeight.w500, // Medium for warm background
    letterSpacing: 0.01 * 14, // +0.01em
    height: 1.5,
  );

  static final bodySm = GoogleFonts.plusJakartaSans(
    fontSize: 12, // 0.75rem
    fontWeight: FontWeight.w500,
    letterSpacing: 0.015 * 12,
    height: 1.4,
  );

  // === LABEL VOICE — Plus Jakarta Sans ===
  // Micro-copy, status badges
  static final labelLg = GoogleFonts.plusJakartaSans(
    fontSize: 14, // 0.875rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0.02 * 14,
    height: 1.4,
  );

  static final labelMd = GoogleFonts.plusJakartaSans(
    fontSize: 12, // 0.75rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0.03 * 12, // +0.03em
    height: 1.3,
  );

  static final labelSm = GoogleFonts.plusJakartaSans(
    fontSize: 10, // 0.625rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0.04 * 10,
    height: 1.3,
  );

  // === LEGACY SUPPORT ===
  // Maintaining compatibility during migration
  static final h1 = headlineLg;
  static final h2 = headlineMd;
  static final h3 = headlineSm;
  static final caption = labelSm;
}
