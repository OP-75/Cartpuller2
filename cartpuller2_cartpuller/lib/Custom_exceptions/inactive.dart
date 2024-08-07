class InactiveUserException implements Exception {
  final String message;

  const InactiveUserException(this.message);

  @override
  String toString() => message;
}
