import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/app_exception.dart';
import '../models/product.dart';

/// Fetches product data from the Fake Store API over HTTP.
class ProductRemoteDataSource {
  ProductRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 15);

  Future<List<Product>> fetchProducts() async {
    final http.Response response;
    try {
      response = await _client
          .get(Uri.parse(ApiConstants.products))
          .timeout(_timeout);
    } on TimeoutException {
      throw const AppException(
        'The request timed out. Check your connection and try again.',
      );
    } catch (_) {
      throw const AppException(
        "We couldn't load the store right now. Check your connection and try again.",
      );
    }

    if (response.statusCode != 200) {
      throw AppException(
        'Something went wrong (error ${response.statusCode}). Please try again.',
      );
    }

    try {
      final decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      throw const AppException('We received an unexpected response.');
    }
  }
}
