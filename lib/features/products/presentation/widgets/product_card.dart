import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../data/models/product.dart';
import 'price_text.dart';
import 'product_image.dart';

/// Grid product card (style 0): square image on top with a glass category
/// pill and favorite button, then title, rating, and serif price.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
    this.serifPrice = true,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;
  final bool serifPrice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: colors.border)),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Hero(
                          tag: 'product-image-${product.id}',
                          child: ProductImage(product: product),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _CategoryPill(category: product.category),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: FavoriteButton(
                          isFavorite: isFavorite,
                          onToggle: onToggleFavorite,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 11, 13, 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.manrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                          letterSpacing: -0.1,
                          height: 1.32,
                        ),
                      ),
                      const Spacer(),
                      _RatingRow(product: product),
                      const SizedBox(height: 7),
                      PriceText(
                        value: product.price,
                        size: 19,
                        serif: serifPrice,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(Icons.star_rounded, size: 14, color: colors.star),
        const SizedBox(width: 4),
        Text(
          product.rating.rate.toStringAsFixed(1),
          style: AppTypography.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '· ${product.rating.count}',
            overflow: TextOverflow.ellipsis,
            style: AppTypography.manrope(
              fontSize: 12,
              color: colors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = formatCategory(
      category,
    ).replaceAll("'s Clothing", '').replaceAll(' Clothing', '');
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          color: colors.glass,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label.toUpperCase(),
            style: AppTypography.manrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
