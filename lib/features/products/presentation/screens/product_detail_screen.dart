import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../data/models/product.dart';
import '../widgets/price_text.dart';
import '../widgets/product_image.dart';
import '../widgets/star_rating.dart';

/// Detail page: hero image, floating controls, category + rating pills,
/// serif title, 5-star row, price, and description.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isFavorite = ref.watch(
      favoritesProvider.select((favs) => favs.contains(product.id)),
    );
    final topInset = MediaQuery.of(context).padding.top;
    // Responsive hero height (scales with the screen, within sensible bounds).
    final heroHeight = (MediaQuery.sizeOf(context).height * 0.42).clamp(
      240.0,
      380.0,
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // Scrollable content (hero image sits behind the floating controls).
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, topInset + 10, 20, 8),
                      child: SizedBox(
                        height: heroHeight,
                        child: Hero(
                          tag: 'product-image-${product.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusHero,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.border),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusHero,
                                ),
                              ),
                              child: ProductImage(
                                product: product,
                                padding: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _Content(product: product),
                  ],
                ),
              ),
            ),
          ),

          // Floating back / share / favorite controls.
          Positioned(
            top: topInset + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _GlassCircle(
                  icon: Icons.chevron_left,
                  semanticLabel: 'Back',
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                Row(
                  children: [
                    _GlassCircle(
                      icon: Icons.ios_share,
                      semanticLabel: 'Share',
                      iconSize: 18,
                      onTap: () {},
                    ),
                    const SizedBox(width: 9),
                    FavoriteButton(
                      isFavorite: isFavorite,
                      size: 40,
                      onToggle: () => _toggleFavorite(context, ref, isFavorite),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(BuildContext context, WidgetRef ref, bool wasFavorite) {
    ref.read(favoritesProvider.notifier).toggle(product.id);
    _showToast(
      context,
      wasFavorite ? 'Removed from favorites' : 'Added to favorites',
      Icons.favorite,
      context.colors.favorite,
    );
  }
}

void _showToast(
  BuildContext context,
  String message,
  IconData icon,
  Color iconColor,
) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2A30)
            : const Color(0xFF1A1917),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        duration: const Duration(milliseconds: 1600),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 9),
            Text(
              message,
              style: AppTypography.manrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
}

class _Content extends StatelessWidget {
  const _Content({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _CategoryBadge(category: product.category),
              _RatingBadge(product: product),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            product.title,
            style: AppTypography.newsreader(
              fontSize: 27,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              letterSpacing: -0.4,
              height: 1.18,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              StarRating(value: product.rating.rate, size: 17),
              const SizedBox(width: 10),
              Text(
                '${product.rating.rate.toStringAsFixed(1)} out of 5',
                style: AppTypography.manrope(
                  fontSize: 13.5,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PriceText(value: product.price, size: 30),
          const SizedBox(height: 16),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: 16),
          Text(
            'DESCRIPTION',
            style: AppTypography.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: AppTypography.manrope(
              fontSize: 15,
              color: isDark ? const Color(0xFFC9C6C0) : const Color(0xFF4A463F),
              height: 1.62,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        formatCategory(category).toUpperCase(),
        style: AppTypography.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colors.accent,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : colors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 13, color: colors.star),
          const SizedBox(width: 5),
          Text(
            product.rating.rate.toStringAsFixed(1),
            style: AppTypography.manrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '· ${product.rating.count} reviews',
            style: AppTypography.manrope(
              fontSize: 12.5,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.iconSize = 22,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.10),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: colors.glass,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Semantics(
                  button: true,
                  label: semanticLabel,
                  child: Icon(icon, size: iconSize, color: colors.textPrimary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
