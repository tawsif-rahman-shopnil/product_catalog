import 'package:flutter/foundation.dart';

/// Aggregate rating for a product: average [rate] and number of [count]s.
@immutable
class Rating {
  const Rating({required this.rate, required this.count});

  final double rate;
  final int count;

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Rating && other.rate == rate && other.count == count;

  @override
  int get hashCode => Object.hash(rate, count);
}
