enum DatabaseExceptionKind { generic, network }

class DatabaseException implements Exception {
  const DatabaseException(
    this.message, {
    this.code,
    this.kind = DatabaseExceptionKind.generic,
  });

  const DatabaseException.network(this.message, {this.code})
    : kind = DatabaseExceptionKind.network;

  final String message;
  final String? code;
  final DatabaseExceptionKind kind;

  bool get isNetwork => kind == DatabaseExceptionKind.network;

  @override
  String toString() => 'DatabaseException($kind, $code): $message';
}
