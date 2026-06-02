/// A user-facing error with a friendly message for the error state UI.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}
