import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/shops/presentation/widgets/shops_list.dart';
import 'package:makanak/shared/widgets/search_text_field.dart';

class ShopsListViewBody extends StatelessWidget {
  const ShopsListViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 48.0, left: 24, right: 24),
      children: [
        Center(
          child: Text(
            'نفسك في ايه؟',
            style: TextStyles.extraBold30.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
        ),
        const Gap(32),
        const SearchTextField(hintText: 'ابحث عن المكان الي نفسك فيه..'),
        const Gap(32),
        const ShopsList(),
        const Gap(24),
      ],
    );
  }
}
