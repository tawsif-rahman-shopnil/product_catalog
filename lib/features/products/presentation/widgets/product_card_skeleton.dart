import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shimmer.dart';

/// Shimmering placeholder card shown in the grid during the initial load.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer(
      baseColor: colors.surfaceAlt,
      highlightColor: colors.card,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ColoredBox(color: colors.surfaceAlt),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(colors, widthFactor: 1),
                  const SizedBox(height: 9),
                  _bar(colors, widthFactor: 0.7),
                  const SizedBox(height: 15),
                  _bar(colors, widthFactor: 0.4, height: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(
    AppColors colors, {
    required double widthFactor,
    double height = 11,
  }) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
