import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/models/product.dart';
import 'products_provider.dart';

/// Sentinel category key for the "Favorites" filter.
const String kFavoritesCategory = '__fav';

/// Selectable category filters shown as chips.
class ProductCategory {
  const ProductCategory(this.key, this.label);
  final String key;
  final String label;
}

const List<ProductCategory> kCategories = [
  ProductCategory('all', 'All'),
  ProductCategory("men's clothing", 'Men'),
  ProductCategory("women's clothing", 'Women'),
  ProductCategory('jewelery', 'Jewelry'),
  ProductCategory('electronics', 'Tech'),
  ProductCategory(kFavoritesCategory, 'Favorites'),
];

/// Number of products revealed per pagination "page". The grid renders this
/// many items, then loads another page as the user scrolls toward the end.
const int kProductsPageSize = 8;

/// How many items are currently revealed in the grid. Grows by
/// [kProductsPageSize] as the user scrolls; reset to one page whenever the
/// search query or category changes so the list starts from the top.
final visibleCountProvider = StateProvider<int>((ref) => kProductsPageSize);

/// The live search query. Search runs locally over the already-loaded list,
/// updating on every keystroke (no network call).
final searchQueryProvider = StateProvider<String>((ref) => '');

/// The currently selected category chip.
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

/// Products after applying the category filter and the local search query.
final filteredProductsProvider = Provider<List<Product>>((ref) {
  final all = ref.watch(productsProvider).valueOrNull ?? const <Product>[];
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final favorites = ref.watch(favoritesProvider);

  Iterable<Product> list = all;

  if (category == kFavoritesCategory) {
    list = list.where((p) => favorites.contains(p.id));
  } else if (category != 'all') {
    list = list.where((p) => p.category == category);
  }

  if (query.isNotEmpty) {
    list = list.where(
      (p) =>
          p.title.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query),
    );
  }

  return list.toList(growable: false);
});
