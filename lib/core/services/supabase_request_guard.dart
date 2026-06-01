import 'dart:async';
import 'dart:io';

import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/services/request_timeout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseRequestGuard {
  const SupabaseRequestGuard._();

  static Future<T> run<T>(
    Future<T> Function() request, {
    Duration timeout = RequestTimeout.normal,
  }) async {
    try {
      return await request().timeout(timeout);
    } on TimeoutException {
      throw const DatabaseException.network(
        'Request timed out',
        code: 'request_timeout',
      );
    } on SocketException {
      throw const DatabaseException.network(
        'Network request failed',
        code: 'network_error',
      );
    } on PostgrestException catch (error) {
      if (_looksLikeNetworkPostgrestError(error)) {
        throw DatabaseException.network(
          error.message,
          code: error.code ?? 'network_error',
        );
      }

      rethrow;
    } catch (error) {
      if (_looksLikeNetworkError(error)) {
        throw DatabaseException.network('$error', code: 'network_error');
      }

      rethrow;
    }
  }

  static bool _looksLikeNetworkPostgrestError(PostgrestException error) {
    return _looksLikeNetworkMessage(
      [
        error.message,
        error.details,
        error.hint,
        error.code,
      ].join(' '),
    );
  }

  static bool _looksLikeNetworkError(Object error) {
    if (error is SocketException || error is TimeoutException) {
      return true;
    }

    final type = error.runtimeType.toString().toLowerCase();
    final message = '$error'.toLowerCase();

    if (type.contains('clientexception') &&
        _looksLikeNetworkMessage(message)) {
      return true;
    }

    return _looksLikeNetworkMessage(message);
  }

  static bool _looksLikeNetworkMessage(String message) {
    final normalizedMessage = message.toLowerCase();

    return normalizedMessage.contains('socket') ||
        normalizedMessage.contains('network') ||
        normalizedMessage.contains('connection') ||
        normalizedMessage.contains('clientexception') ||
        normalizedMessage.contains('failed host lookup') ||
        normalizedMessage.contains('connection closed') ||
        normalizedMessage.contains('connection refused') ||
        normalizedMessage.contains('timed out') ||
        normalizedMessage.contains('timeout') ||
        normalizedMessage.contains('dns');
  }
}
