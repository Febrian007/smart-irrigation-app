import 'package:material_ui/material_ui.dart';

/// Palet gelap "night field": dasar biru-malam dengan aksen menyala.
class AppPalette {
  AppPalette._();

  // Brand
  static const Color primary = Color(0xFF8B93FF);
  static const Color primaryDark = Color(0xFF4A52D6);
  static const Color primarySoft = Color(0x298B93FF);

  /// Warna teks/ikon di atas aksen terang (primary, mint, amber, coral, sky).
  static const Color onAccent = Color(0xFF080D1A);

  // Surfaces & Borders
  static const Color background = Color(0xFF080D1A);
  static const Color surface = Color(0xFF111A2C);
  static const Color surfaceHigh = Color(0xFF1B2640);
  static const Color border = Color(0xFF25324F);
  static const Color divider = Color(0xFF1C2740);

  // Typography
  static const Color textPrimary = Color(0xFFF2F5FF);
  static const Color textSecondary = Color(0xFFA9B4CF);
  static const Color textMuted = Color(0xFF7C88A6);

  // Semantic Accents
  static const Color mint = Color(0xFF2EE6A6);
  static const Color mintSoft = Color(0x242EE6A6);
  static const Color amber = Color(0xFFFFB648);
  static const Color amberSoft = Color(0x24FFB648);
  static const Color coral = Color(0xFFFF6B7A);
  static const Color coralSoft = Color(0x24FF6B7A);
  static const Color sky = Color(0xFF4CC2FF);
  static const Color skySoft = Color(0x244CC2FF);
}
