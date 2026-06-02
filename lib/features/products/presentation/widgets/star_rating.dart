import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A 5-star row with partial fill — the last lit star clips to the fractional
/// part of [value] (e.g. 3.6 → three full stars + a 60%-filled fourth).
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.value, this.size = 17});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final fill = (value - i).clamp(0.0, 1.0);
        return Padding(
          padding: EdgeInsets.only(right: i < 4 ? 1.5 : 0),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: size,
                  color: colors.textTertiary.withValues(alpha: 0.5),
                ),
                ClipRect(
                  clipper: _FractionClipper(fill),
                  child: Icon(
                    Icons.star_rounded,
                    size: size,
                    color: colors.star,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _FractionClipper extends CustomClipper<Rect> {
  const _FractionClipper(this.fraction);
  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_FractionClipper oldClipper) =>
      oldClipper.fraction != fraction;
}
