import 'package:flutter/services.dart';
import 'package:makanak/core/deep_linking/deep_link_navigator.dart';
import 'package:makanak/core/deep_linking/install_referrer_parser.dart';
import 'package:makanak/core/helper/print_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstallReferrerService {
  InstallReferrerService(
    this._parser,
    this._deepLinkNavigator, {
    MethodChannel methodChannel = const MethodChannel(_channelName),
    Future<SharedPreferences> Function()? sharedPreferencesProvider,
  }) : _methodChannel = methodChannel,
       _sharedPreferencesProvider =
           sharedPreferencesProvider ?? SharedPreferences.getInstance;

  static const String _channelName = 'makanak/install_referrer';
  static const String _methodName = 'getInstallReferrer';
  static const String _processedDedupeKey =
      'processed_install_referrer_dedupe_key';

  final InstallReferrerParser _parser;
  final DeepLinkNavigator _deepLinkNavigator;
  final MethodChannel _methodChannel;
  final Future<SharedPreferences> Function() _sharedPreferencesProvider;

  Future<void>? _initializeFuture;

  Future<void> initialize() {
    return _initializeFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      final referrer = await _methodChannel.invokeMethod<String>(_methodName);
      final rawReferrer = referrer?.trim() ?? '';
      if (rawReferrer.isEmpty) {
        return;
      }

      final link = _parser.parse(rawReferrer);
      if (link == null) {
        return;
      }

      final prefs = await _sharedPreferencesProvider();
      if (prefs.getString(_processedDedupeKey) == link.dedupeKey) {
        return;
      }

      await _deepLinkNavigator.handle(link);
      await prefs.setString(_processedDedupeKey, link.dedupeKey);
    } catch (error, stackTrace) {
      PrintHelper.error(
        'Failed to process install referrer.',
        error: error,
        stackTrace: stackTrace,
        tag: 'InstallReferrer',
      );
    }
  }
}
