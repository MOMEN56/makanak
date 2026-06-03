import 'package:flutter/foundation.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/helper/print_helper.dart';
import 'package:makanak/core/services/request_timeout.dart';
import 'package:makanak/core/services/supabase_request_guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseRemoteDataSource {
  const SupabaseRemoteDataSource(this.client);

  @protected
  final SupabaseClient client;

  @protected
  Future<T> guardedRequest<T>(
    Future<T> Function() request, {
    String? operation,
    bool log = false,
    Duration timeout = RequestTimeout.normal,
  }) async {
    try {
      return await SupabaseRequestGuard.run(request, timeout: timeout);
    } on PostgrestException catch (error) {
      throw databaseException(error, operation: operation, log: log);
    } on DatabaseException catch (error) {
      if (log) {
        _logDatabaseException(operation ?? runtimeType.toString(), error);
      }
      rethrow;
    } catch (error, stackTrace) {
      throw unexpectedDatabaseException(
        operation: operation,
        error: error,
        stackTrace: stackTrace,
        log: log,
      );
    }
  }

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
    PrintHelper.error(
      'Supabase $operation failed: '
      'code=${error.code}, message=${error.message}, details=${error.details}',
      tag: 'Supabase',
    );
  }

  void _logDatabaseException(String operation, DatabaseException error) {
    PrintHelper.error(
      'Supabase $operation failed: '
      'kind=${error.kind}, code=${error.code}, message=${error.message}',
      tag: 'Supabase',
    );
  }

  void _logUnexpectedException(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) {
    PrintHelper.error(
      'Supabase $operation failed unexpectedly.',
      error: error,
      stackTrace: stackTrace,
      tag: 'Supabase',
    );
  }
}
