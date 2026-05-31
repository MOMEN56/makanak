import 'package:equatable/equatable.dart';

class RemoteAppConfigModel extends Equatable {
  const RemoteAppConfigModel({
    required this.platform,
    required this.minSupportedVersion,
    required this.latestVersion,
    required this.blockedVersions,
    required this.maintenanceMode,
    required this.forceUpdateMessage,
    required this.maintenanceMessage,
    required this.updateUrl,
    required this.isActive,
  });

  final String platform;
  final String minSupportedVersion;
  final String? latestVersion;
  final List<String> blockedVersions;
  final bool maintenanceMode;
  final String forceUpdateMessage;
  final String maintenanceMessage;
  final String updateUrl;
  final bool isActive;

  factory RemoteAppConfigModel.fromJson(Map<String, dynamic> json) {
    return RemoteAppConfigModel(
      platform: _readString(json['platform']),
      minSupportedVersion: _readString(json['min_supported_version']),
      latestVersion: _readOptionalString(json['latest_version']),
      blockedVersions: _readStringList(json['blocked_versions']),
      maintenanceMode: _readBool(json['maintenance_mode']),
      forceUpdateMessage: _readString(json['force_update_message']),
      maintenanceMessage: _readString(json['maintenance_message']),
      updateUrl: _readString(json['update_url']),
      isActive: _readBool(json['is_active']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'min_supported_version': minSupportedVersion,
      'latest_version': latestVersion,
      'blocked_versions': blockedVersions,
      'maintenance_mode': maintenanceMode,
      'force_update_message': forceUpdateMessage,
      'maintenance_message': maintenanceMessage,
      'update_url': updateUrl,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
    platform,
    minSupportedVersion,
    latestVersion,
    blockedVersions,
    maintenanceMode,
    forceUpdateMessage,
    maintenanceMessage,
    updateUrl,
    isActive,
  ];

  static bool _readBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  static String _readString(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static String? _readOptionalString(Object? value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  static List<String> _readStringList(Object? value) {
    if (value is! List) return const [];

    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
