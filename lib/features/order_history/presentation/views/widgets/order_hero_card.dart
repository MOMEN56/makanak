import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/order_history/data/models/order_model.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_meta_chip.dart';
import 'package:makanak/shared/widgets/network_image_with_placeholder.dart';

class OrderHeroCard extends StatelessWidget {
  const OrderHeroCard({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final preview = SizedBox(
          width: isCompact ? double.infinity : 120,
          height: 120,
          child: NetworkImageWithPlaceholder(
            imageUrl: order.previewImageUrl,
            height: 120,
            width: 120,
            cacheWidth: 280,
            placeholderColor: AppColors.white.withValues(alpha: 0.18),
            iconColor: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        );

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.orderTotalPaid,
              style: TextStyles.medium12.copyWith(
                color: AppColors.white.withValues(alpha: 0.86),
              ),
            ),
            const Gap(6),
            Text(
              AppStrings.priceInEgyptianPounds(order.totalPaid),
              style: TextStyles.bold24.copyWith(
                color: AppColors.white,
                height: 1.1,
              ),
            ),
            const Gap(14),
            OrderMetaChip(
              label: AppStrings.orderItemsCount(order.totalItemsCount),
              backgroundColor: AppColors.white.withValues(alpha: 0.16),
              foregroundColor: AppColors.white,
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.darkerShade(AppColors.primaryColor, 0.08),
                AppColors.primaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.24),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child:
              isCompact
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [preview, const Gap(16), content],
                  )
                  : Row(
                    children: [
                      Expanded(child: content),
                      const Gap(16),
                      preview,
                    ],
                  ),
        );
      },
    );
  }
}
