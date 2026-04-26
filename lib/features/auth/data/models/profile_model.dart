import 'package:makanak/features/auth/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    super.fullName,
    super.role = 'customer',
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId?.toString();
    if (id == null || id.isEmpty) {
      throw FormatException(
        'ProfileModel.fromJson failed: missing or empty "id" field in json: $json',
      );
    }

    return ProfileModel(
      id: id,
      fullName: json['full_name']?.toString(),
      role: json['role']?.toString() ?? 'customer',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'full_name': fullName, 'role': role}
      ..removeWhere((key, value) => value == null);
  }
}
