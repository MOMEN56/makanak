import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/assets.dart';
import 'package:makanak/features/shops/presentation/manager/shops_cubit/shops_cubit.dart';
import 'package:makanak/features/shops/presentation/manager/shops_cubit/shops_state.dart';
import 'package:makanak/features/shops/presentation/views/widgets/shops_header.dart';
import 'package:makanak/features/shops/presentation/views/widgets/shops_list.dart';
import 'package:makanak/features/shops/presentation/views/widgets/shops_skeleton.dart';
import 'package:makanak/shared/widgets/keyboard_dismiss_on_tap.dart';
import 'package:makanak/shared/widgets/message_emoji_widget.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class ShopsViewBody extends StatelessWidget {
  const ShopsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopsCubit, ShopsState>(
      builder: (context, state) {
        return KeyboardDismissOnTap(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: AppResponsive.fromLTRB(context, 24, 48, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: ShopsHeader(
                    onSearchChanged: context.read<ShopsCubit>().searchShops,
                  ),
                ),
              ),
              if (state case ShopsSuccess(:final shops) when shops.isNotEmpty)
                SliverToBoxAdapter(
                  child: Gap(AppResponsive.spacing(context, 8)),
                ),
              switch (state) {
                ShopsInitial() || ShopsLoading() => const ShopsSkeleton(),
                ShopsSuccess(:final shops) =>
                  shops.isEmpty
                      ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: MessageEmojiWidget(
                          image: Assets.assetsIconsIdkEmoji,
                          text: AppStrings.shopsEmptySearch,
                        ),
                      )
                      : ShopsList(shops: shops),
                ShopsFailure(:final message) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: StateMessage(
                    message: message,
                    onRetry: context.read<ShopsCubit>().fetchShops,
                  ),
                ),
              },
              const SliverToBoxAdapter(child: Gap(24)),
            ],
          ),
        );
      },
    );
  }
}
