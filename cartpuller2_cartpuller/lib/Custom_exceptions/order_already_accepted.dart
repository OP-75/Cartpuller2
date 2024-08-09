class OrderAlreadyAcceptedException implements Exception {
  final String message;

  const OrderAlreadyAcceptedException(this.message);

  @override
  String toString() => message;
}
