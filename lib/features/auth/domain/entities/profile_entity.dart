import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.id,
    this.fullName,
    this.role = 'customer',
  });

  final String id;
  final String? fullName;
  final String role;

  @override
  List<Object?> get props => [id, fullName, role];
}
