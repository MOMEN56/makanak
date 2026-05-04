import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class OrderHistoryViewBody extends StatelessWidget {
  const OrderHistoryViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'سجل الطلبات',
        style: TextStyles.bold24.copyWith(color: AppColors.primaryDarkColor),
      ),
    );
  }
}
