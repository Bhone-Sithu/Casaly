
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTypography {
  // Headings
  static final h1 = GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600);
  static final h2 = GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600);
  static final h3 = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600);

  // Body
  static final bodyLg  = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400);
  static final bodyMd  = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400);
  static final bodySm  = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400);

  // Labels
  static final labelLg = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500);
  static final labelMd = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500);
  static final labelSm = GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500);

  // Caption
  static final caption = GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400);
}
