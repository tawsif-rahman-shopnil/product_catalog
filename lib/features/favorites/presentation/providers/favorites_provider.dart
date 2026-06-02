import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';

/// Holds the set of favorite product ids. Hydrated from persistent storage on
/// first read and written back on every toggle.
class FavoritesNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => ref.read(favoritesRepositoryProvider).load();

  void toggle(int productId) {
    final next = Set<int>.from(state);
    if (!next.add(productId)) {
      // add() returns false when the id was already present → it's a removal.
      next.remove(productId);
    }
    state = next;
    ref.read(favoritesRepositoryProvider).save(next);
  }

  bool isFavorite(int productId) => state.contains(productId);
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<int>>(
  FavoritesNotifier.new,
);

/// Convenience: number of saved favorites (for the app-bar badge).
final favoritesCountProvider = Provider<int>(
  (ref) => ref.watch(favoritesProvider).length,
);
