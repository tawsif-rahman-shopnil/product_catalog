import '../datasources/product_remote_data_source.dart';
import '../models/product.dart';

/// Repository boundary for product data. The presentation layer depends on
/// this abstraction rather than the concrete data source.
abstract interface class ProductRepository {
  Future<List<Product>> getProducts();
}

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<List<Product>> getProducts() => _remote.fetchProducts();
}
