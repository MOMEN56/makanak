class DatabaseException implements Exception {
  const DatabaseException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'DatabaseException($code): $message';
}
