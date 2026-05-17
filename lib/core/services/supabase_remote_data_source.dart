import 'package:flutter/foundation.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseRemoteDataSource {
  const SupabaseRemoteDataSource(this.client);

  @protected
  final SupabaseClient client;

  @protected
  String requireAuthenticatedUserId() {
    final userId = client.auth.currentSession?.user.id.trim();
    if (userId == null || userId.isEmpty) {
      throw const DatabaseException('User is not authenticated');
    }

    return userId;
  }

  @protected
  DatabaseException databaseException(
    PostgrestException error, {
    String? operation,
    bool log = false,
  }) {
    if (log) {
      _logPostgrestException(operation ?? runtimeType.toString(), error);
    }

    return DatabaseException(error.message, code: error.code);
  }

  @protected
  DatabaseException unexpectedDatabaseException({
    String? operation,
    Object? error,
    StackTrace? stackTrace,
    bool log = false,
  }) {
    if (log && error != null && stackTrace != null) {
      _logUnexpectedException(
        operation ?? runtimeType.toString(),
        error,
        stackTrace,
      );
    }

    return const DatabaseException('Unexpected database error');
  }

  void _logPostgrestException(String operation, PostgrestException error) {
    if (!kDebugMode) return;

    debugPrint(
      'Supabase $operation failed: '
      'code=${error.code}, message=${error.message}, details=${error.details}',
    );
  }

  void _logUnexpectedException(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) {
    if (!kDebugMode) return;

    debugPrint('Supabase $operation failed unexpectedly: $error');
    debugPrint('$stackTrace');
  }
}
