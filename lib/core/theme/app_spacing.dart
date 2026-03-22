
abstract class AppSpacing {
  // === EDITORIAL SPACING SYSTEM ===
  // Based on 8px grid with emphasis on 2rem (32px) for card separation
  
  static const xs   = 4.0;   // 0.25rem
  static const sm   = 8.0;   // 0.5rem
  static const md   = 12.0;  // 0.75rem
  static const lg   = 16.0;  // 1rem
  static const xl   = 24.0;  // 1.5rem
  static const xxl  = 32.0;  // 2rem - Primary section spacing
  static const xxxl = 48.0;  // 3rem - Large section breaks

  // === SEMANTIC SPACING ===
  // Follows the "No-Line Rule" - boundaries through spacing
  static const cardPadding = 24.0;      // 1.5rem - Internal card padding
  static const cardSeparation = 32.0;   // 2rem - The sacred "Spacing 6" between cards
  static const screenPadding = 24.0;    // 1.5rem - Screen edge padding
  static const sectionBreak = 48.0;     // 3rem - Major section separation
  static const inlineSpacing = 12.0;    // 0.75rem - Inline element spacing
  static const stackSpacing = 16.0;     // 1rem - Vertical stack spacing
  
  // === LEGACY SUPPORT ===
  static const cardGap = cardSeparation;
  static const sectionGap = sectionBreak;
}
