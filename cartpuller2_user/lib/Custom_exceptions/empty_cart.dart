class EmptyCartException implements Exception {
  final String message;

  const EmptyCartException(this.message);

  @override
  String toString() => message;
}
