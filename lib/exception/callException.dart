class CallException implements Exception {
  final String message;

  CallException(this.message);

  @override
  String toString() => 'CallException: $message';
}