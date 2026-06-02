import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/core/providers.dart';
import 'package:product_catalog/features/favorites/data/favorites_repository.dart';
import 'package:product_catalog/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> makeContainer([
    Map<String, Object> initial = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(initial);
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  group('FavoritesRepository', () {
    test('round-trips a set of ids through SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = FavoritesRepository(prefs);

      expect(repo.load(), isEmpty);
      await repo.save({3, 7, 11});
      expect(repo.load(), {3, 7, 11});
    });
  });

  group('FavoritesNotifier', () {
    test('hydrates from persisted favorites on launch', () async {
      final container = await makeContainer({
        'folio.favorites.v1': ['1', '2'],
      });
      addTearDown(container.dispose);

      expect(container.read(favoritesProvider), {1, 2});
    });

    test('toggle adds and removes ids and persists them', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(favoritesProvider.notifier);

      notifier.toggle(42);
      expect(container.read(favoritesProvider), {42});

      notifier.toggle(42);
      expect(container.read(favoritesProvider), isEmpty);
    });
  });
}
