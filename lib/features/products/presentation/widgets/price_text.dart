import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Editorial price treatment: serif numerals with a superscript `$` and
/// smaller cents — the signature move from the design.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.value,
    this.size = 19,
    this.serif = true,
    this.color,
  });

  final double value;
  final double size;
  final bool serif;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolved = color ?? colors.textPrimary;
    final parts = value.toStringAsFixed(2).split('.');
    final dollars = parts[0];
    final cents = parts[1];

    final base = serif
        ? AppTypography.newsreader(
            fontSize: size,
            fontWeight: FontWeight.w600,
            color: resolved,
            height: 1,
          )
        : AppTypography.manrope(
            fontSize: size,
            fontWeight: FontWeight.w800,
            color: resolved,
            letterSpacing: -0.4,
            height: 1,
          );
    final small = base.copyWith(fontSize: size * 0.62);

    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Transform.translate(
              offset: Offset(0, size * 0.06),
              child: Text(r'$', style: small),
            ),
          ),
          TextSpan(text: dollars, style: base),
          TextSpan(text: '.$cents', style: small),
        ],
      ),
      maxLines: 1,
    );
  }
}
