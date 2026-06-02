import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/models/product.dart';

/// Loads the product catalogue and exposes it as an [AsyncValue], which maps
/// directly onto the loading / error / data states in the UI.
class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() {
    return ref.watch(productRepositoryProvider).getProducts();
  }

  /// Re-fetches the catalogue. Used by the app-bar refresh button, the error
  /// retry button, and pull-to-refresh.
  ///
  /// Keeps the previously loaded data visible while the fetch is in flight so
  /// pull-to-refresh shows the spinner over the existing grid rather than
  /// collapsing to skeletons.
  Future<void> refresh() async {
    state = const AsyncValue<List<Product>>.loading().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).getProducts(),
    );
  }
}

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);
