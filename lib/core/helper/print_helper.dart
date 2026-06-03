import 'package:flutter/foundation.dart';

abstract final class PrintHelper {
  static void log(Object? message, {String? tag}) {
    _write(message, tag: tag);
  }

  static void warning(Object? message, {String? tag}) {
    _write(message, level: 'WARNING', tag: tag);
  }

  static void error(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (!kDebugMode) {
      return;
    }

    _debugPrint(_format(message, level: 'ERROR', tag: tag));

    if (error != null) {
      _debugPrint(
        _format(error, level: 'ERROR', tag: tag, label: 'Details'),
      );
    }

    if (stackTrace != null) {
      _debugPrint(
        _format(
          stackTrace,
          level: 'ERROR',
          tag: tag,
          label: 'StackTrace',
        ),
      );
    }
  }

  static void tag(String tag, Object? message) {
    log(message, tag: tag);
  }

  static String _format(
    Object? message, {
    String? level,
    String? tag,
    String? label,
  }) {
    final buffer = StringBuffer();

    if (_hasValue(level)) {
      buffer.write('[${level!.trim()}] ');
    }

    if (_hasValue(tag)) {
      buffer.write('[${tag!.trim()}] ');
    }

    if (_hasValue(label)) {
      buffer.write('${label!.trim()}: ');
    }

    buffer.write(message);
    return buffer.toString();
  }

  static bool _hasValue(String? value) =>
      value != null && value.trim().isNotEmpty;

  static void _write(
    Object? message, {
    String? level,
    String? tag,
  }) {
    if (!kDebugMode) {
      return;
    }

    _debugPrint(_format(message, level: level, tag: tag));
  }

  static void _debugPrint(String message) => debugPrint(message);
}
