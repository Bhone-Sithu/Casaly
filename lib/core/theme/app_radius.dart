
abstract class AppRadius {
  // === EDITORIAL RADIUS SYSTEM ===
  // Tactile, friendly shapes that feel hand-crafted
  
  static const xs = 4.0;     // 0.25rem - Micro elements
  static const sm = 8.0;     // 0.5rem - Badges, small chips
  static const md = 16.0;    // 1rem - Default radius (was 12px)
  static const lg = 32.0;    // 2rem - Primary cards (editorial requirement)
  static const xl = 48.0;    // 3rem - Pill buttons, major UI elements
  static const pill = 999.0; // Full pill shape

  // === SEMANTIC USAGE ===
  static const card = lg;      // 2rem - All primary cards must use this
  static const button = xl;    // 3rem - Pill-shaped friendly buttons
  static const input = md;     // 1rem - Input fields
  static const badge = sm;     // 0.5rem - Status badges
  static const sheet = xl;     // 3rem - Bottom sheets and modals
  
  // Specialized Components
  static const taskChip = xl;    // 3rem - Gamified task chips
  static const glassCard = lg;   // 2rem - Glass morphism cards
}
