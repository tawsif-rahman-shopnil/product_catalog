import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/core/providers.dart';
import 'package:product_catalog/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:product_catalog/features/products/data/models/product.dart';
import 'package:product_catalog/features/products/data/models/rating.dart';
import 'package:product_catalog/features/products/data/repositories/product_repository.dart';
import 'package:product_catalog/features/products/presentation/providers/product_filter_provider.dart';
import 'package:product_catalog/features/products/presentation/providers/products_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepository implements ProductRepository {
  _FakeRepository(this.products);
  final List<Product> products;
  @override
  Future<List<Product>> getProducts() async => products;
}

Product _product(int id, String title, String category) => Product(
  id: id,
  title: title,
  price: 10,
  description: '',
  category: category,
  image: '',
  rating: const Rating(rate: 4, count: 1),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final catalogue = [
    _product(1, 'Mens Cotton Jacket', "men's clothing"),
    _product(2, 'Womens Ring', 'jewelery'),
    _product(3, 'Gaming Laptop', 'electronics'),
    _product(4, 'Casual T-Shirt', "men's clothing"),
  ];

  Future<ProviderContainer> makeContainer() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        productRepositoryProvider.overrideWithValue(_FakeRepository(catalogue)),
      ],
    );
    // Resolve the async product load before exercising the filter.
    await container.read(productsProvider.future);
    return container;
  }

  group('filteredProductsProvider', () {
    test('returns the full catalogue with no filter', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      expect(container.read(filteredProductsProvider), hasLength(4));
    });

    test('filters by search query on title (case-insensitive)', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).state = 'laptop';
      final result = container.read(filteredProductsProvider);

      expect(result, hasLength(1));
      expect(result.single.id, 3);
    });

    test('filters by category', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      container.read(selectedCategoryProvider.notifier).state =
          "men's clothing";
      expect(container.read(filteredProductsProvider), hasLength(2));
    });

    test('favorites filter only returns favorited products', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      container.read(favoritesProvider.notifier).toggle(2);
      container.read(selectedCategoryProvider.notifier).state =
          kFavoritesCategory;

      final result = container.read(filteredProductsProvider);
      expect(result, hasLength(1));
      expect(result.single.id, 2);
    });

    test('combines category and search filters', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      container.read(selectedCategoryProvider.notifier).state =
          "men's clothing";
      container.read(searchQueryProvider.notifier).state = 'shirt';

      final result = container.read(filteredProductsProvider);
      expect(result, hasLength(1));
      expect(result.single.id, 4);
    });
  });
}
