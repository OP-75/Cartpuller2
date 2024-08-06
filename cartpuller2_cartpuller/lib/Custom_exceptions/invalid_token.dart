class InvalidTokenException implements Exception {
  final String message;

  const InvalidTokenException(this.message);

  @override
  String toString() => message;
}
