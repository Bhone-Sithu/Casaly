
import 'package:flutter/material.dart';

abstract class AppTypography {
  static const _fontFamily = 'Inter';

  // Headings
  static const h1 = TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: _fontFamily);
  static const h2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: _fontFamily);
  static const h3 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: _fontFamily);

  // Body
  static const bodyLg  = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, fontFamily: _fontFamily);
  static const bodyMd  = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: _fontFamily);
  static const bodySm  = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, fontFamily: _fontFamily);

  // Labels
  static const labelLg = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: _fontFamily);
  static const labelMd = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: _fontFamily);
  static const labelSm = TextStyle(fontSize: 10, fontWeight: FontWeight.w500, fontFamily: _fontFamily);

  // Caption
  static const caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, fontFamily: _fontFamily);
}
