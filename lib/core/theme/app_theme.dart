import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds the light and dark [ThemeData], each sharing a
/// `ColorScheme.fromSeed(seedColor: accent)` and the [AppColors] extension.
abstract final class AppTheme {
  /// Shared spacing scale from the design: 4 · 8 · 12 · 16 · 22 · 28.
  static const double radiusCard = 20;
  static const double radiusField = 14;
  static const double radiusHero = 26;

  static ThemeData light() => _build(Brightness.light, AppColors.light);
  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.accent,
      brightness: brightness,
    ).copyWith(primary: colors.accent, surface: colors.background);

    final base = brightness == Brightness.dark
        ? ThemeData.dark()
        : ThemeData.light();

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: GoogleFonts.manropeTextTheme(
        base.textTheme,
      ).apply(bodyColor: colors.textPrimary, displayColor: colors.textPrimary),
      splashColor: colors.accent.withValues(alpha: 0.08),
      highlightColor: colors.accent.withValues(alpha: 0.04),
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }
}
