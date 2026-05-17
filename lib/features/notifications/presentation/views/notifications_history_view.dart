import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/notifications/presentation/notifications_strings.dart';
import 'package:makanak/features/notifications/presentation/views/widgets/notifications_history_view_body.dart';

class NotificationsHistoryView extends StatelessWidget {
  const NotificationsHistoryView({super.key});

  static const String routeName = '/notifications-history';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            NotificationsStrings.notifications,
            style: TextStyles.bold20.copyWith(
              color: AppColors.primaryDarkColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.greyBackground,
          surfaceTintColor: AppColors.greyBackground,
        ),
        body: const NotificationsHistoryViewBody(),
      ),
    );
  }
}
