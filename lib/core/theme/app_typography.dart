import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// Editorial type pairing from the design handoff:
/// Manrope for UI, Newsreader (serif) for screen titles and prices.
abstract final class AppTypography {
  /// Sans-serif used for everything except editorial titles/prices.
  static TextStyle manrope({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double letterSpacing = 0,
    double? height,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Serif used for the signature editorial titles and prices.
  static TextStyle newsreader({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double letterSpacing = 0,
    double? height,
  }) {
    return GoogleFonts.newsreader(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Uppercase tracking label ("FOLIO", "DESCRIPTION").
  static TextStyle eyebrow({required Color color, double fontSize = 11.5}) {
    return manrope(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 1.2,
    );
  }
}
