import 'dart:convert';

import 'package:makanak/features/app_remote_config/data/models/remote_app_config_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRemoteConfigLocalDataSource {
  const AppRemoteConfigLocalDataSource();

  static const String _cacheKeyPrefix = 'app_remote_config_cache_';

  Future<void> saveConfig({
    required String platform,
    required RemoteAppConfigModel config,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey(platform), jsonEncode(config.toJson()));
  }

  Future<RemoteAppConfigModel?> readConfig({required String platform}) async {
    final prefs = await SharedPreferences.getInstance();
    final rawConfig = prefs.getString(_cacheKey(platform));
    if (rawConfig == null || rawConfig.isEmpty) return null;

    try {
      final decoded = jsonDecode(rawConfig);
      if (decoded is! Map) {
        await clearConfig(platform: platform);
        return null;
      }

      return RemoteAppConfigModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      await clearConfig(platform: platform);
      return null;
    }
  }

  Future<void> clearConfig({required String platform}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey(platform));
  }

  String _cacheKey(String platform) {
    return '$_cacheKeyPrefix${platform.trim()}';
  }
}
