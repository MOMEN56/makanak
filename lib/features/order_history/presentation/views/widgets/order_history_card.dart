import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/helper_fun/order_date_formatter.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/order_history/data/models/order_model.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_meta_chip.dart';
import 'package:makanak/shared/widgets/network_image_with_placeholder.dart';

class OrderHistoryCard extends StatelessWidget {
  const OrderHistoryCard({super.key, required this.order, required this.onTap});

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1.0, 1.5);
    final baseCardHeight = AppResponsive.height(context, 130);
    final cardHeight = baseCardHeight + ((textScaleFactor - 1) * 210);
    final cardRadius = AppResponsive.radius(context, 12);
    final imageWidth = AppResponsive.width(context, 82);
    final badgeTextWidth = AppResponsive.width(context, 90);

    return SizedBox(
      width: double.infinity,
      height: cardHeight,
      child: Material(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: imageWidth,
                child: SizedBox.expand(
                  child: NetworkImageWithPlaceholder(
                    imageUrl: order.previewImageUrl,
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheWidth: 260,
                    placeholderIcon: Icons.storefront_outlined,
                    placeholderColor: AppColors.primaryDarkColor,
                    iconColor: AppColors.white,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: AppResponsive.all(context, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.orderTotalPaid,
                              style: TextStyles.medium12.copyWith(
                                color: AppColors.white.withValues(alpha: 0.82),
                              ),
                            ),
                            const Gap(6),
                            Text(
                              AppStrings.priceInEgyptianPounds(order.totalPaid),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.bold16.copyWith(
                                color: AppColors.white,
                                height: 1.15,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              formatOrderDate(order.createdAt).date,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.medium10.copyWith(
                                color: AppColors.white.withValues(alpha: 0.82),
                              ),
                            ),
                            if (formatOrderDate(order.createdAt).time != null)
                              Text(
                                formatOrderDate(order.createdAt).time!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.medium10.copyWith(
                                  color: AppColors.white.withValues(
                                    alpha: 0.82,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          OrderStatusBadge(
                            status: order.status,
                            compact: true,
                            maxTextWidth: badgeTextWidth,
                          ),
                          OrderMetaChip(
                            label: AppStrings.orderItemsCount(
                              order.totalItemsCount,
                            ),
                            backgroundColor: AppColors.white.withValues(
                              alpha: 0.16,
                            ),
                            foregroundColor: AppColors.white,
                            maxTextWidth: badgeTextWidth,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
