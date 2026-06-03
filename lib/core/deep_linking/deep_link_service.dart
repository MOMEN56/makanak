import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:makanak/core/deep_linking/app_deep_link.dart';
import 'package:makanak/core/deep_linking/deep_link_navigator.dart';
import 'package:makanak/core/deep_linking/deep_link_parser.dart';
import 'package:makanak/core/helper/print_helper.dart';

class DeepLinkService {
  DeepLinkService(
    this._deepLinkParser,
    this._deepLinkNavigator, {
    AppLinks? appLinks,
  }) : _appLinks = appLinks ?? AppLinks();

  final DeepLinkParser _deepLinkParser;
  final DeepLinkNavigator _deepLinkNavigator;
  final AppLinks _appLinks;

  StreamSubscription<Uri>? _linkSubscription;
  bool _isInitialized = false;
  String? _lastInitialLinkKey;
  DateTime? _lastInitialLinkHandledAt;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        unawaited(_handleIncomingUri(uri));
      },
      onError: (Object error, StackTrace stackTrace) {
        _debugLog(
          'Failed to read an incoming app link.',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri == null) {
        _clearRecentInitialLink();
        return;
      }

      final initialLink = _deepLinkParser.parse(initialUri);
      if (initialLink == null) {
        _clearRecentInitialLink();
        return;
      }

      _lastInitialLinkKey = initialLink.dedupeKey;
      _lastInitialLinkHandledAt = DateTime.now();
      await _deepLinkNavigator.handle(initialLink);
    } catch (error, stackTrace) {
      _debugLog(
        'Failed to read the initial app link.',
        error: error,
        stackTrace: stackTrace,
      );
      _clearRecentInitialLink();
    }
  }

  Future<void> dispose() async {
    await _linkSubscription?.cancel();
    _linkSubscription = null;
    _isInitialized = false;
    _clearRecentInitialLink();
  }

  Future<void> _handleIncomingUri(Uri uri) async {
    final link = _deepLinkParser.parse(uri);
    if (link == null) {
      return;
    }

    if (_shouldIgnoreDuplicateInitialLink(link)) {
      return;
    }

    await _deepLinkNavigator.handle(link);
  }

  bool _shouldIgnoreDuplicateInitialLink(AppDeepLink link) {
    final handledAt = _lastInitialLinkHandledAt;
    if (_lastInitialLinkKey != link.dedupeKey || handledAt == null) {
      return false;
    }

    final isDuplicate =
        DateTime.now().difference(handledAt) <= const Duration(seconds: 2);
    if (isDuplicate) {
      _clearRecentInitialLink();
      return true;
    }

    _clearRecentInitialLink();
    return false;
  }

  void _clearRecentInitialLink() {
    _lastInitialLinkKey = null;
    _lastInitialLinkHandledAt = null;
  }
}

void _debugLog(String message, {Object? error, StackTrace? stackTrace}) {
  if (error == null && stackTrace == null) {
    PrintHelper.tag('DeepLink', message);
    return;
  }

  PrintHelper.error(
    message,
    error: error,
    stackTrace: stackTrace,
    tag: 'DeepLink',
  );
}
