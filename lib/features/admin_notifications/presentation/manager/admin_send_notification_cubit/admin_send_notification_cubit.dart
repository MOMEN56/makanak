import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/admin_notifications/data/services/manual_notification_exception.dart';
import 'package:makanak/features/admin_notifications/data/services/manual_notification_service.dart';
import 'package:makanak/features/admin_notifications/presentation/manager/admin_send_notification_cubit/admin_send_notification_state.dart';

class AdminSendNotificationCubit extends Cubit<AdminSendNotificationState> {
  AdminSendNotificationCubit(this._manualNotificationService)
    : super(const AdminSendNotificationState());

  final ManualNotificationService _manualNotificationService;

  Future<void> sendNotification({
    required String title,
    required String body,
    String userId = '',
    Map<String, dynamic> data = const {},
  }) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: AdminSendNotificationStatus.loading,
        clearMessage: true,
      ),
    );

    try {
      final normalizedUserId = userId.trim();
      if (normalizedUserId.isEmpty) {
        await _manualNotificationService.sendToAllUsers(
          title: title,
          body: body,
          data: data,
        );
      } else {
        await _manualNotificationService.sendToUser(
          userId: normalizedUserId,
          title: title,
          body: body,
          data: data,
        );
      }

      emit(
        const AdminSendNotificationState(
          status: AdminSendNotificationStatus.success,
          message: AppStrings.adminNotificationSuccess,
        ),
      );
    } on ManualNotificationException catch (error) {
      emit(
        AdminSendNotificationState(
          status: AdminSendNotificationStatus.failure,
          message: error.message,
        ),
      );
    } catch (_) {
      emit(
        const AdminSendNotificationState(
          status: AdminSendNotificationStatus.failure,
          message: AppStrings.adminNotificationSendError,
        ),
      );
    }
  }

  void clearFeedback() {
    if (state.status == AdminSendNotificationStatus.initial &&
        state.message == null) {
      return;
    }

    emit(
      state.copyWith(
        status: AdminSendNotificationStatus.initial,
        clearMessage: true,
      ),
    );
  }
}
