import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/features/products/data/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('parses a complete product payload', () {
      final product = Product.fromJson(const {
        'id': 1,
        'title': 'Fjallraven Backpack',
        'price': 109.95,
        'description': 'Your perfect pack for everyday use.',
        'category': "men's clothing",
        'image': 'https://example.com/img.jpg',
        'rating': {'rate': 3.9, 'count': 120},
      });

      expect(product.id, 1);
      expect(product.title, 'Fjallraven Backpack');
      expect(product.price, 109.95);
      expect(product.category, "men's clothing");
      expect(product.rating.rate, 3.9);
      expect(product.rating.count, 120);
    });

    test('coerces integer prices to double', () {
      final product = Product.fromJson(const {
        'id': 2,
        'title': 'T-Shirt',
        'price': 22,
        'description': '',
        'category': "men's clothing",
        'image': '',
        'rating': {'rate': 4, 'count': 259},
      });

      expect(product.price, 22.0);
      expect(product.rating.rate, 4.0);
    });

    test('falls back to safe defaults for missing fields', () {
      final product = Product.fromJson(const {'id': 3});

      expect(product.title, '');
      expect(product.price, 0);
      expect(product.rating.rate, 0);
      expect(product.rating.count, 0);
    });

    test('products with the same id are equal', () {
      Product make(int id) => Product.fromJson({
        'id': id,
        'title': 'x',
        'price': 1,
        'description': '',
        'category': '',
        'image': '',
        'rating': const {'rate': 1, 'count': 1},
      });

      expect(make(5), make(5));
      expect(make(5).hashCode, make(5).hashCode);
      expect(make(5), isNot(make(6)));
    });
  });
}
