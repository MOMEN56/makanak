import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:makanak/features/app_remote_config/app_remote_config_strings.dart';
import 'package:makanak/features/app_remote_config/data/data_sources/app_remote_config_local_data_source.dart';
import 'package:makanak/features/app_remote_config/data/data_sources/app_remote_config_remote_data_source.dart';
import 'package:makanak/features/app_remote_config/data/models/remote_app_config_model.dart';
import 'package:makanak/features/app_remote_config/domain/entities/app_access_result.dart';
import 'package:makanak/features/app_remote_config/domain/repos/app_remote_config_repo.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppRemoteConfigRepoImpl implements AppRemoteConfigRepo {
  const AppRemoteConfigRepoImpl(this._remoteDataSource, this._localDataSource);

  static const Duration _requestTimeout = Duration(seconds: 3);

  final AppRemoteConfigRemoteDataSource _remoteDataSource;
  final AppRemoteConfigLocalDataSource _localDataSource;

  @override
  Future<AppAccessResult> checkAppAccess() async {
    final platform = _currentPlatform();
    if (platform == null) {
      return const AppAccessResult.allowed();
    }

    final currentVersion = await _readCurrentVersion();
    if (currentVersion == null) {
      return const AppAccessResult.allowed();
    }

    final remoteConfig = await _fetchRemoteConfig(platform);
    if (remoteConfig != null) {
      return _resolveAccess(
        config: remoteConfig,
        currentVersion: currentVersion,
      );
    }

    final cachedConfig = await _readCachedConfig(platform);
    if (cachedConfig == null) {
      return const AppAccessResult.allowed();
    }

    return _resolveAccess(config: cachedConfig, currentVersion: currentVersion);
  }

  Future<RemoteAppConfigModel?> _fetchRemoteConfig(String platform) async {
    try {
      final config = await _remoteDataSource
          .fetchActiveConfig(platform: platform)
          .timeout(_requestTimeout);

      if (config == null) {
        await _localDataSource.clearConfig(platform: platform);
        return null;
      }

      await _localDataSource.saveConfig(platform: platform, config: config);
      return config;
    } on TimeoutException catch (error, stackTrace) {
      _logFallback(
        'App remote config request timed out. Falling back to cache.',
        error,
        stackTrace,
      );
      return null;
    } catch (error, stackTrace) {
      _logFallback(
        'App remote config request failed. Falling back to cache.',
        error,
        stackTrace,
      );
      return null;
    }
  }

  Future<RemoteAppConfigModel?> _readCachedConfig(String platform) async {
    try {
      return await _localDataSource.readConfig(platform: platform);
    } catch (error, stackTrace) {
      _logFallback(
        'Cached app remote config could not be read. Allowing startup.',
        error,
        stackTrace,
      );
      return null;
    }
  }

  Future<String?> _readCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version.trim();
      if (version.isEmpty) return null;

      return version;
    } catch (error, stackTrace) {
      _logFallback(
        'App version could not be read. Allowing startup.',
        error,
        stackTrace,
      );
      return null;
    }
  }

  AppAccessResult _resolveAccess({
    required RemoteAppConfigModel config,
    required String currentVersion,
  }) {
    if (config.maintenanceMode) {
      return AppAccessResult(
        status: AppAccessStatus.maintenance,
        message: _resolveMessage(
          config.maintenanceMessage,
          AppRemoteConfigStrings.maintenanceFallbackMessage,
        ),
      );
    }

    if (_isBlockedVersion(currentVersion, config.blockedVersions)) {
      return AppAccessResult(
        status: AppAccessStatus.forceUpdate,
        message: _resolveMessage(
          config.forceUpdateMessage,
          AppRemoteConfigStrings.forceUpdateFallbackMessage,
        ),
        updateUrl: _normalizeOptionalValue(config.updateUrl),
      );
    }

    if (_compareVersions(currentVersion, config.minSupportedVersion) < 0) {
      return AppAccessResult(
        status: AppAccessStatus.forceUpdate,
        message: _resolveMessage(
          config.forceUpdateMessage,
          AppRemoteConfigStrings.forceUpdateFallbackMessage,
        ),
        updateUrl: _normalizeOptionalValue(config.updateUrl),
      );
    }

    return const AppAccessResult.allowed();
  }

  bool _isBlockedVersion(String currentVersion, List<String> blockedVersions) {
    return blockedVersions.any(
      (blockedVersion) => _compareVersions(currentVersion, blockedVersion) == 0,
    );
  }

  int _compareVersions(String left, String right) {
    final leftSegments = _parseVersion(left);
    final rightSegments = _parseVersion(right);
    final maxLength =
        leftSegments.length > rightSegments.length
            ? leftSegments.length
            : rightSegments.length;

    for (var index = 0; index < maxLength; index++) {
      final leftValue = index < leftSegments.length ? leftSegments[index] : 0;
      final rightValue =
          index < rightSegments.length ? rightSegments[index] : 0;

      if (leftValue != rightValue) {
        return leftValue.compareTo(rightValue);
      }
    }

    return 0;
  }

  List<int> _parseVersion(String version) {
    final normalized = version.trim();
    if (normalized.isEmpty) return const [0];

    return normalized
        .split('.')
        .map(_parseVersionSegment)
        .toList(growable: false);
  }

  int _parseVersionSegment(String segment) {
    final match = RegExp(r'\d+').firstMatch(segment.trim());
    return int.tryParse(match?.group(0) ?? '') ?? 0;
  }

  String _resolveMessage(String? value, String fallback) {
    final normalized = _normalizeOptionalValue(value);
    if (normalized == null) return fallback;

    return normalized;
  }

  String? _normalizeOptionalValue(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  String? _currentPlatform() {
    if (kIsWeb) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return null;
    }
  }

  void _logFallback(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;

    debugPrint(message);
    debugPrint('$error');
    debugPrint('$stackTrace');
  }
}
