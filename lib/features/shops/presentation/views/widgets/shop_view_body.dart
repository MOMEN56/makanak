import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/assets.dart';
import 'package:makanak/features/shops/presentation/manager/shops_cubit/shops_cubit.dart';
import 'package:makanak/features/shops/presentation/manager/shops_cubit/shops_state.dart';
import 'package:makanak/features/shops/presentation/views/widgets/shops_header.dart';
import 'package:makanak/features/shops/presentation/views/widgets/shops_list.dart';
import 'package:makanak/shared/widgets/custom_loading_indicator.dart';
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
              switch (state) {
                ShopsInitial() || ShopsLoading() => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: CustomLoadingIndicator(),
                ),
                ShopsSuccess(:final shops) =>
                  shops.isEmpty
                      ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: MessageEmojiWidget(
                          image: Assets.assetsIconsIdkEmoji,
                          text:
                              '\u0644\u0627 \u062a\u0648\u062c\u062f \u0645\u062d\u0644\u0627\u062a \u0645\u062a\u0627\u062d\u0629 \u062d\u0627\u0644\u064a\u0627.',
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
