import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/cart/data/models/confirming_order_address_model.dart';
import 'package:makanak/features/cart/presentation/views/widgets/confirming_card_widget.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    required this.canChangeAddress,
    required this.onChangeAddress,
    this.primaryColor = AppColors.primaryColor,
  });

  final ConfirmingOrderAddressModel address;
  final bool canChangeAddress;
  final VoidCallback onChangeAddress;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return ConfirmingCard(
      primaryColor: primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: primaryColor, size: 22),
              const Gap(8),
              Expanded(
                child: Text(
                  AppStrings.deliveryAddress,
                  style: TextStyles.bold16.copyWith(
                    color: AppColors.shopNameColor,
                  ),
                ),
              ),
              if (canChangeAddress)
                TextButton.icon(
                  onPressed: onChangeAddress,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text(AppStrings.change),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    textStyle: TextStyles.semiBold14,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          const Gap(12),
          Text(
            address.title,
            style: TextStyles.semiBold14.copyWith(
              color: AppColors.darkerShade(primaryColor),
            ),
          ),
          const Gap(6),
          Text(
            address.details,
            style: TextStyles.regular14.copyWith(
              color: AppColors.shopCategoryColor,
              height: 1.45,
            ),
          ),
          const Gap(8),
          _AddressInfo(icon: Icons.phone_outlined, text: address.phone),
          if (address.notes.isNotEmpty) ...[
            const Gap(6),
            _AddressInfo(icon: Icons.notes_outlined, text: address.notes),
          ],
        ],
      ),
    );
  }
}

class _AddressInfo extends StatelessWidget {
  const _AddressInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.lightGrey, size: 18),
        const Gap(6),
        Expanded(
          child: Text(
            text,
            style: TextStyles.medium12.copyWith(color: AppColors.lightGrey),
          ),
        ),
      ],
    );
  }
}
