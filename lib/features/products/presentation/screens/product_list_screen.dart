import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/widgets/folio_brand_lockup.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/models/product.dart';
import '../providers/product_filter_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/product_grid_delegate.dart';
import '../widgets/search_field.dart';
import '../widgets/state_views.dart';
import 'product_detail_screen.dart';

/// The product listing screen: frosted app bar, local search, category chips,
/// a responsive product grid, pull-to-refresh, and loading/error/empty states.
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Reveals the next page once the user scrolls near the end of the grid.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 400) return;

    final total = ref.read(filteredProductsProvider).length;
    final visible = ref.read(visibleCountProvider);
    if (visible >= total) return;
    ref.read(visibleCountProvider.notifier).state =
        (visible + kProductsPageSize).clamp(0, total);
  }

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  Future<void> _refresh() => ref.read(productsProvider.notifier).refresh();

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  void _resetPagination() {
    ref.read(visibleCountProvider.notifier).state = kProductsPageSize;
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final productsAsync = ref.watch(productsProvider);
    final isInitialLoading = productsAsync.isLoading && !productsAsync.hasValue;

    // Restart pagination from the first page whenever the result set changes
    // (new search query or category), so the grid always begins at the top.
    ref.listen(searchQueryProvider, (_, _) => _resetPagination());
    ref.listen(selectedCategoryProvider, (_, _) => _resetPagination());

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: colors.accent,
        backgroundColor: colors.card,
        edgeOffset: MediaQuery.of(context).padding.top + 120,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildHeader(),
            if (isInitialLoading)
              const SliverToBoxAdapter(child: LoadingGrid())
            else if (productsAsync.hasError && !productsAsync.hasValue)
              _RemainingViewportSliver(
                child: ErrorView(
                  message: _errorMessage(productsAsync.error),
                  onRetry: _refresh,
                ),
              )
            else
              ..._buildResults(),
          ],
        ),
      ),
    );
  }

  String _errorMessage(Object? error) {
    if (error is AppException) return error.message;
    return "We couldn't load the store right now. "
        'Check your connection and try again.';
  }

  List<Widget> _buildResults() {
    final products = ref.watch(filteredProductsProvider);
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);

    if (products.isEmpty) {
      return [
        _RemainingViewportSliver(
          child: EmptyView(
            query: query,
            onClear: () {
              _clearSearch();
              ref.read(selectedCategoryProvider.notifier).state = 'all';
            },
          ),
        ),
      ];
    }

    // Pagination: reveal only the first N items and grow as the user scrolls.
    final visibleCount = ref
        .watch(visibleCountProvider)
        .clamp(0, products.length);
    final visible = products.take(visibleCount).toList(growable: false);
    final hasMore = visibleCount < products.length;

    final colors = context.colors;
    final countLabel =
        '${products.length} ${products.length == 1 ? 'item' : 'items'}'
        '${category == kFavoritesCategory ? ' saved' : ''}';

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
        sliver: SliverToBoxAdapter(
          child: Text(
            countLabel,
            style: AppTypography.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, hasMore ? 8 : 28),
        sliver: SliverGrid.builder(
          gridDelegate: kProductGridDelegate,
          itemCount: visible.length,
          itemBuilder: (context, index) {
            final product = visible[index];
            final isFavorite = ref.watch(
              favoritesProvider.select((favs) => favs.contains(product.id)),
            );
            return ProductCard(
              product: product,
              isFavorite: isFavorite,
              onTap: () => _openProduct(product),
              onToggleFavorite: () =>
                  ref.read(favoritesProvider.notifier).toggle(product.id),
            );
          },
        ),
      ),
      if (hasMore)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            child: Center(
              child: SizedBox(
                height: 26,
                width: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: colors.accent,
                ),
              ),
            ),
          ),
        ),
    ];
  }

  Widget _buildHeader() {
    final colors = context.colors;
    final favCount = ref.watch(favoritesCountProvider);
    final category = ref.watch(selectedCategoryProvider);
    final favoritesActive = category == kFavoritesCategory;
    final topInset = MediaQuery.of(context).padding.top;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderDelegate(
        topInset: topInset,
        // Clamp upward text scaling so the fixed-extent header can't overflow
        // for users with large accessibility text (smaller scales pass through).
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.glass,
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                // Pad the content below the status bar, but let the frosted glass
                // fill behind it so nothing scrolls through the notch / clock.
                child: Padding(
                  padding: EdgeInsets.only(top: topInset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App bar row.
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: const FolioBrandLockup(
                                  logoSize: 42,
                                  fontSize: 31,
                                  gap: 0,
                                  textYOffset: 4,
                                ),
                              ),
                            ),
                            _IconSquareButton(
                              icon:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                              semanticLabel: 'Toggle theme',
                              onTap: () =>
                                  ref.read(themeModeProvider.notifier).toggle(),
                            ),
                            const SizedBox(width: 9),
                            _FavoritesToggle(
                              active: favoritesActive,
                              count: favCount,
                              onTap: () =>
                                  ref
                                      .read(selectedCategoryProvider.notifier)
                                      .state = favoritesActive
                                  ? 'all'
                                  : kFavoritesCategory,
                            ),
                          ],
                        ),
                      ),
                      // Search field.
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                        child: SearchField(
                          controller: _searchController,
                          onChanged: (value) =>
                              ref.read(searchQueryProvider.notifier).state =
                                  value,
                          onClear: _clearSearch,
                        ),
                      ),
                      // Category chips.
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                          itemCount: kCategories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final cat = kCategories[index];
                            return CategoryChip(
                              label: cat.label,
                              active: category == cat.key,
                              onTap: () =>
                                  ref
                                      .read(selectedCategoryProvider.notifier)
                                      .state = cat
                                      .key,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gives state views a concrete remaining-viewport height without asking them
/// for intrinsic dimensions. This avoids the LayoutBuilder + SliverFillRemaining
/// intrinsic sizing assertion while keeping the message vertically centered.
class _RemainingViewportSliver extends StatelessWidget {
  const _RemainingViewportSliver({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final height =
            constraints.viewportMainAxisExtent -
            constraints.precedingScrollExtent;

        return SliverToBoxAdapter(
          child: SizedBox(
            height: height.clamp(0.0, double.infinity),
            child: child,
          ),
        );
      },
    );
  }
}

/// Persistent header sizing for the frosted app bar (app bar + search + chips).
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate({required this.topInset, required this.child});

  final double topInset;
  final Widget child;

  // Brand/app row (~60) + search (44+10) + chips (34) + bottom spacing (12).
  double get _contentHeight => 60 + 54 + 34 + 12;

  @override
  double get maxExtent => topInset + _contentHeight;

  @override
  double get minExtent => topInset + _contentHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Fill the full declared extent so the sliver's paintExtent matches its
    // layoutExtent (the pinned header never shrinks: minExtent == maxExtent).
    // The status-bar inset is applied inside [child] so the frosted glass
    // extends up behind the status bar.
    return SizedBox(height: maxExtent, child: child);
  }

  @override
  bool shouldRebuild(_HeaderDelegate oldDelegate) =>
      oldDelegate.topInset != topInset || oldDelegate.child != child;
}

/// Square 40×40 outlined icon button used in the app bar.
class _IconSquareButton extends StatelessWidget {
  const _IconSquareButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Semantics(
            button: true,
            label: semanticLabel,
            child: Icon(icon, size: 19, color: colors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _FavoritesToggle extends StatelessWidget {
  const _FavoritesToggle({
    required this.active,
    required this.count,
    required this.onTap,
  });

  final bool active;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: active ? colors.accent : colors.card,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? Colors.transparent : colors.border,
                ),
              ),
              child: Semantics(
                button: true,
                label: 'Favorites',
                child: Icon(
                  active ? Icons.favorite : Icons.favorite_border,
                  size: 19,
                  color: active ? Colors.white : colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        if (count > 0 && !active)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17),
              height: 17,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.favorite,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: colors.background, width: 2),
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: AppTypography.manrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
