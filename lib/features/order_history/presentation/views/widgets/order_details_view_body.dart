import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/shared/widgets/order_summary_card_widget.dart';
import 'package:makanak/features/order_history/data/models/order_model.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_details_header.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_details_info_card.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_details_product_card.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_delivery_status_stepper.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_hero_card.dart';
import 'package:makanak/shared/widgets/address_card_widget.dart';

class OrderDetailsViewBody extends StatelessWidget {
  const OrderDetailsViewBody({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: AppResponsive.all(context, AppSpacing.screenEdge),
        children: [
          OrderDetailsHeader(order: order),
          const Gap(20),
          OrderDeliveryStatusStepper(
            currentStatus: order.status,
            cancellationReason: order.rejectionReason,
          ),
          const Gap(20),
          OrderHeroCard(order: order),
          const Gap(20),
          Text(
            AppStrings.orderItems,
            style: TextStyles.bold20.copyWith(color: AppColors.shopNameColor),
          ),
          const Gap(12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OrderDetailsProductCard(item: item),
            ),
          ),
          if (order.address != null) ...[
            AddressCard(
              address: order.address!,
              canChangeAddress: false,
              onChangeAddress: () {},
            ),
          ],
          const Gap(12),
          OrderDetailsInfoCard(order: order),
          const Gap(12),
          OrderSummaryCard(
            itemsTotal: order.itemsTotal,
            shippingPrice: order.shippingPrice,
            orderTotal: order.totalPaid,
          ),
          const Gap(18),
        ],
      ),
    );
  }
}
