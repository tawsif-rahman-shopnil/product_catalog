import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Folio brand lockup: the supplied logo mark forms the "F", followed by
/// "olio" text to complete the wordmark.
class FolioBrandLockup extends StatelessWidget {
  const FolioBrandLockup({
    super.key,
    this.logoSize = 40,
    this.fontSize = 28,
    this.gap = 7,
    this.textYOffset = 3,
    this.centered = false,
  });

  final double logoSize;
  final double fontSize;
  final double gap;
  final double textYOffset;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: 'Folio',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: centered
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: logoSize,
              height: logoSize,
              child: Image.asset('assets/logo.png', fit: BoxFit.contain),
            ),
            SizedBox(width: gap),
            Transform.translate(
              offset: Offset(0, textYOffset),
              child: Text(
                'olio',
                style: AppTypography.newsreader(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
