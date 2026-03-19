
import 'package:flutter/material.dart';

abstract class AppColors {
  // === PRIMARY — Garden Green ===
  // Fresh leaves, summer grass, life growing
  // Use for: brand, primary actions, hero cards, nav active, "clean/done"
  static const green50  = Color(0xFFEAF5E4);
  static const green100 = Color(0xFFB8DCA4);
  static const green200 = Color(0xFF8BBC78);
  static const green400 = Color(0xFF4A9E60);  // ← Primary brand color
  static const green600 = Color(0xFF3A7A44);
  static const green800 = Color(0xFF245030);

  // === SECONDARY — Sunset Orange ===
  // Golden hour warmth, urgency without stress
  // Use for: timers, alerts, washer status, warm accents
  static const orange50  = Color(0xFFFFF0E0);
  static const orange100 = Color(0xFFFCCFA0);
  static const orange200 = Color(0xFFF0A060);
  static const orange400 = Color(0xFFE8884A);  // ← Secondary brand color
  static const orange600 = Color(0xFFC06830);
  static const orange800 = Color(0xFF8A4820);

  // === ACCENT — Sunflower ===
  // Cheerful, optimistic, summer fields
  // Use for: shopping lists, info badges, counts, gentle reminders
  static const yellow50  = Color(0xFFFEF8E0);
  static const yellow100 = Color(0xFFF5E08A);
  static const yellow200 = Color(0xFFF2C24E);
  static const yellow400 = Color(0xFFD4A420);
  static const yellow600 = Color(0xFFA08420);
  static const yellow800 = Color(0xFF6A5810);

  // === ACCENT — Warm Berry ===
  // Strawberry warmth, excitement without aggression
  // Use for: events, social features, missed tasks, errors
  static const berry50  = Color(0xFFFDEAEA);
  static const berry100 = Color(0xFFF0AAAA);
  static const berry200 = Color(0xFFE87070);
  static const berry400 = Color(0xFFD04848);
  static const berry600 = Color(0xFFA03434);
  static const berry800 = Color(0xFF6A2020);

  // === NEUTRALS — Warm Cream ===
  // Every surface has a warm tint. No cold grays anywhere.
  static const cream50  = Color(0xFFFFFAF0);  // ← Page background
  static const cream100 = Color(0xFFFFF3E0);  // ← Card highlight bg
  static const cream200 = Color(0xFFEDE0CC);  // ← Borders
  static const cream300 = Color(0xFFD0C4B0);  // ← Light borders
  static const cream400 = Color(0xFFA09080);  // ← Placeholder text
  static const cream600 = Color(0xFF5A4E42);  // ← Secondary text
  static const cream800 = Color(0xFF302820);  // ← Primary text

  // === SEMANTIC (mapped from above) ===
  static const success = green400;
  static const warning = yellow400;
  static const error   = berry400;
  static const info    = orange400;
}
