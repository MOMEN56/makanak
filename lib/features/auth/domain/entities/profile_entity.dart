import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.id,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.role = 'customer',
  });

  final String id;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final String role;

  @override
  List<Object?> get props => [id, fullName, email, avatarUrl, role];
}
