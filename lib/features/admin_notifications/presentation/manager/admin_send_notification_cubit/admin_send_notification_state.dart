import 'package:equatable/equatable.dart';

enum AdminSendNotificationStatus { initial, loading, success, failure }

class AdminSendNotificationState extends Equatable {
  const AdminSendNotificationState({
    this.status = AdminSendNotificationStatus.initial,
    this.message,
  });

  final AdminSendNotificationStatus status;
  final String? message;

  bool get isLoading => status == AdminSendNotificationStatus.loading;

  AdminSendNotificationState copyWith({
    AdminSendNotificationStatus? status,
    String? message,
    bool clearMessage = false,
  }) {
    return AdminSendNotificationState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, message];
}
