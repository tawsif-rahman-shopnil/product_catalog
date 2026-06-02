import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:product_catalog/core/error/app_exception.dart';
import 'package:product_catalog/features/products/data/datasources/product_remote_data_source.dart';
import 'package:product_catalog/features/products/data/repositories/product_repository.dart';

const _validBody = '''
[
  {"id":1,"title":"Backpack","price":109.95,"description":"d",
   "category":"men's clothing","image":"http://x/y.jpg",
   "rating":{"rate":3.9,"count":120}}
]
''';

void main() {
  group('ProductRepositoryImpl', () {
    test('returns parsed products on 200', () async {
      final client = MockClient((_) async => http.Response(_validBody, 200));
      final repo = ProductRepositoryImpl(
        ProductRemoteDataSource(client: client),
      );

      final products = await repo.getProducts();

      expect(products, hasLength(1));
      expect(products.single.title, 'Backpack');
    });

    test('throws AppException on a non-200 status', () async {
      final client = MockClient((_) async => http.Response('nope', 500));
      final repo = ProductRepositoryImpl(
        ProductRemoteDataSource(client: client),
      );

      expect(repo.getProducts(), throwsA(isA<AppException>()));
    });

    test('throws AppException on malformed JSON', () async {
      final client = MockClient((_) async => http.Response('{not json', 200));
      final repo = ProductRepositoryImpl(
        ProductRemoteDataSource(client: client),
      );

      expect(repo.getProducts(), throwsA(isA<AppException>()));
    });
  });
}
