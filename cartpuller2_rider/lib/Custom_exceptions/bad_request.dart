class BadRequestException implements Exception {
  final String message;

  const BadRequestException(this.message);

  @override
  String toString() => message;
}
