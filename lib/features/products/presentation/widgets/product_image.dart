import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../data/models/product.dart';

/// Cached product image on a clean background, with a shimmer placeholder
/// while loading and a tinted category fallback if the image fails to load.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.product, this.padding = 16});

  final Product product;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.imageBackground,
      child: SizedBox.expand(
        child: CachedNetworkImage(
          imageUrl: product.image,
          fit: BoxFit.contain,
          imageBuilder: (context, imageProvider) => Padding(
            padding: EdgeInsets.all(padding),
            child: Image(image: imageProvider, fit: BoxFit.contain),
          ),
          placeholder: (context, _) => Shimmer(
            baseColor: colors.surfaceAlt,
            highlightColor: colors.card,
            child: ColoredBox(color: colors.surfaceAlt),
          ),
          errorWidget: (context, _, _) =>
              _CategoryFallback(category: product.category),
        ),
      ),
    );
  }
}

class _CategoryFallback extends StatelessWidget {
  const _CategoryFallback({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = AppColors.categoryTint(category);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.image_outlined, size: 22, color: tint),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatCategory(category),
              textAlign: TextAlign.center,
              style: AppTypography.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Title-cases a category label, preserving the `'s` in "Men's".
String _formatCategory(String category) {
  return category
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ')
      .replaceAll("'S", "'s");
}

/// Shared category formatter for use by cards and the detail screen.
String formatCategory(String category) => _formatCategory(category);
