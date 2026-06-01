import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/notifications/presentation/notifications_strings.dart';
import 'package:makanak/features/notifications/presentation/views/widgets/notifications_history_view_body.dart';

class NotificationsHistoryView extends StatefulWidget {
  const NotificationsHistoryView({super.key});

  static const String routeName = '/notifications-history';

  @override
  State<NotificationsHistoryView> createState() =>
      _NotificationsHistoryViewState();
}

class _NotificationsHistoryViewState extends State<NotificationsHistoryView> {
  bool _isShowingFullScreenNoInternet = false;

  void _handleFullScreenNetworkStateChanged(bool isShowing) {
    if (_isShowingFullScreenNoInternet == isShowing) {
      return;
    }

    setState(() {
      _isShowingFullScreenNoInternet = isShowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar:
            _isShowingFullScreenNoInternet
                ? null
                : AppBar(
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
        body: NotificationsHistoryViewBody(
          onFullScreenNetworkStateChanged: _handleFullScreenNetworkStateChanged,
        ),
      ),
    );
  }
}
