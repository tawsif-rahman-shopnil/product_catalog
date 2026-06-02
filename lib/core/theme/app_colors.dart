import 'package:flutter/material.dart';

/// Semantic color palette for the app, with a light and dark variant.
///
/// Mirrors the design handoff tokens. The [accent] (primary) is configurable;
/// [favorite] and [star] are intentionally constant across themes.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.card,
    required this.surfaceAlt,
    required this.imageBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderStrong,
    required this.accent,
    required this.favorite,
    required this.star,
    required this.glass,
  });

  final Color background;
  final Color card;
  final Color surfaceAlt;
  final Color imageBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color borderStrong;
  final Color accent;
  final Color favorite;
  final Color star;

  /// Translucent fill used for frosted/glass surfaces (app bar, fav buttons).
  final Color glass;

  static const Color _accentLight = Color(0xFF2563EB);
  static const Color _accentDark = Color(0xFF5B8DEF);

  static const AppColors light = AppColors(
    background: Color(0xFFF4F3F1),
    card: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFECEAE6),
    imageBackground: Color(0xFFF7F6F4),
    textPrimary: Color(0xFF1A1917),
    textSecondary: Color(0xFF78736C),
    textTertiary: Color(0xFFAEA89F),
    border: Color(0xFFE8E5E0),
    borderStrong: Color(0xFFDCD8D1),
    accent: _accentLight,
    favorite: Color(0xFFE5484D),
    star: Color(0xFFF59E0B),
    glass: Color(0xC7FFFFFF), // rgba(255,255,255,0.78)
  );

  static const AppColors dark = AppColors(
    background: Color(0xFF0F0F12),
    card: Color(0xFF1A1A1F),
    surfaceAlt: Color(0xFF26262C),
    imageBackground: Color(0xFF202026),
    textPrimary: Color(0xFFF5F4F2),
    textSecondary: Color(0xFFA5A29C),
    textTertiary: Color(0xFF6E6B66),
    border: Color(0x14FFFFFF), // rgba(255,255,255,0.08)
    borderStrong: Color(0x24FFFFFF), // rgba(255,255,255,0.14)
    accent: _accentDark,
    favorite: Color(0xFFFF6369),
    star: Color(0xFFFBBF24),
    glass: Color(0xB81A1A1F), // rgba(26,26,31,0.72)
  );

  /// Soft category tint used for image fallbacks.
  static Color categoryTint(String category) {
    switch (category) {
      case "men's clothing":
        return const Color(0xFF3B82F6);
      case "women's clothing":
        return const Color(0xFFEC4899);
      case 'jewelery':
        return const Color(0xFFD97706);
      case 'electronics':
        return const Color(0xFF10B981);
      default:
        return _accentLight;
    }
  }

  @override
  AppColors copyWith({
    Color? background,
    Color? card,
    Color? surfaceAlt,
    Color? imageBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? borderStrong,
    Color? accent,
    Color? favorite,
    Color? star,
    Color? glass,
  }) {
    return AppColors(
      background: background ?? this.background,
      card: card ?? this.card,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      imageBackground: imageBackground ?? this.imageBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      accent: accent ?? this.accent,
      favorite: favorite ?? this.favorite,
      star: star ?? this.star,
      glass: glass ?? this.glass,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      imageBackground: Color.lerp(imageBackground, other.imageBackground, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      favorite: Color.lerp(favorite, other.favorite, t)!,
      star: Color.lerp(star, other.star, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
    );
  }
}

/// Convenience accessor: `context.colors`.
extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
