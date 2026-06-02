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
import 'package:makanak/shared/widgets/app_snack_bar.dart';
import 'package:makanak/shared/widgets/keyboard_dismiss_on_tap.dart';
import 'package:makanak/shared/widgets/message_emoji_widget.dart';
import 'package:makanak/shared/views/no_internet_view.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class ShopsViewBody extends StatefulWidget {
  const ShopsViewBody({super.key});

  @override
  State<ShopsViewBody> createState() => _ShopsViewBodyState();
}

class _ShopsViewBodyState extends State<ShopsViewBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _restoreSearchText(context.read<ShopsCubit>().appliedQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _restoreSearchText(String query) {
    if (_searchController.text == query) return;

    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopsCubit, ShopsState>(
      listenWhen: _shouldListenToRefreshFailure,
      listener: (context, state) {
        if (state is! ShopsSuccess || state.refreshFailure == null) return;

        _restoreSearchText(context.read<ShopsCubit>().appliedQuery);
        final refreshFailure = state.refreshFailure!;
        if (refreshFailure.isNetwork) {
          AppSnackBar.showNetwork(
            context: context,
            message: refreshFailure.message,
          );
          return;
        }

        AppSnackBar.show(
          context: context,
          message: refreshFailure.message,
          badgeText: AppStrings.retry,
          onBadgeTap: () => context.read<ShopsCubit>().retry(),
        );
      },
      buildWhen: _shouldRebuildShopsView,
      builder: (context, state) {
        if (state is ShopsFailure) {
          return state.failure.isNetwork
              ? NoInternetView(
                onRetry: () => context.read<ShopsCubit>().retry(),
              )
              : SafeArea(
                child: StateMessage(
                  message: state.message,
                  onRetry: () => context.read<ShopsCubit>().retry(),
                ),
              );
        }

        final shouldShowListSpacing = switch (state) {
          ShopsInitial() || ShopsLoading() => true,
          ShopsSuccess(:final shops) => shops.isNotEmpty,
          ShopsFailure() => false,
        };

        return KeyboardDismissOnTap(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: AppResponsive.fromLTRB(context, 24, 48, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: ShopsHeader(
                    controller: _searchController,
                    onSearchChanged: context.read<ShopsCubit>().searchShops,
                  ),
                ),
              ),
              if (shouldShowListSpacing)
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
                ShopsFailure() => const SliverToBoxAdapter(),
              },
              const SliverToBoxAdapter(child: Gap(24)),
            ],
          ),
        );
      },
    );
  }
}

bool _shouldListenToRefreshFailure(ShopsState previous, ShopsState current) {
  return current is ShopsSuccess &&
      current.refreshFailure != null &&
      (previous is! ShopsSuccess ||
          previous.refreshFailureId != current.refreshFailureId);
}

bool _shouldRebuildShopsView(ShopsState previous, ShopsState current) {
  if (previous.runtimeType != current.runtimeType) {
    return true;
  }

  if (previous is ShopsSuccess && current is ShopsSuccess) {
    return previous.shops != current.shops;
  }

  if (previous is ShopsFailure && current is ShopsFailure) {
    return previous.failure != current.failure;
  }

  return false;
}
