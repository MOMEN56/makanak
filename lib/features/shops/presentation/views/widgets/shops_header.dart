import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/shared/widgets/search_text_field.dart';

class ShopsHeader extends StatelessWidget {
  const ShopsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SearchTextField(
          hintText: 'ابحث عن المكان اللي نفسك فيه..',
        ),
        const Gap(32),
      ],
    );
  }
}
