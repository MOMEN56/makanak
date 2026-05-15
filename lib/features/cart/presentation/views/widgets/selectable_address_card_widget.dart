import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/core/models/user_address_model.dart';

class SelectableAddressCard extends StatelessWidget {
  const SelectableAddressCard({
    super.key,
    required this.address,
    required this.isSelected,
    required this.primaryColor,
    this.onSetAsMain,
  });

  final UserAddressModel address;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback? onSetAsMain;

  @override
  Widget build(BuildContext context) {
    final darkerPrimaryColor = AppColors.darkerShade(primaryColor);
    final titleColor = isSelected ? AppColors.white : AppColors.shopNameColor;
    final bodyColor =
        isSelected ? AppColors.white : AppColors.shopCategoryColor;
    final metaColor = isSelected ? AppColors.white : AppColors.lightGrey;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : AppColors.shopCategoryIconBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? darkerPrimaryColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.bold16.copyWith(color: titleColor),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
              ],
            ),
            const Gap(6),
            _MainAddressAction(
              isDefault: address.isDefault,
              isSelected: isSelected,
              primaryColor: primaryColor,
              onSetAsMain: onSetAsMain,
            ),
            if (address.details.trim().isNotEmpty) ...[
              const Gap(8),
              Text(
                address.details,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.regular14.copyWith(
                  color: bodyColor,
                  height: 1.45,
                ),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Icon(Icons.phone_outlined, color: metaColor, size: 18),
                const Gap(6),
                Expanded(
                  child: Text(
                    address.phone,
                    style: TextStyles.medium12.copyWith(color: metaColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MainAddressAction extends StatelessWidget {
  const _MainAddressAction({
    required this.isDefault,
    required this.isSelected,
    required this.primaryColor,
    this.onSetAsMain,
  });

  final bool isDefault;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback? onSetAsMain;

  @override
  Widget build(BuildContext context) {
    if (isDefault) {
      return Align(
        alignment: Alignment.centerRight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : primaryColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              AppStrings.defaultAddress,
              style: TextStyles.medium12.copyWith(
                color: isSelected ? primaryColor : AppColors.white,
              ),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: onSetAsMain,
        icon: Icon(
          Icons.star_border_rounded,
          color: isSelected ? AppColors.white : primaryColor,
          size: 18,
        ),
        label: Text(
          AppStrings.makeDefault,
          style: TextStyles.medium12.copyWith(
            color: isSelected ? AppColors.white : primaryColor,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 28),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
