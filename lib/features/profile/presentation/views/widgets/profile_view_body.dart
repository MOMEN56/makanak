import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_cubit.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/features/profile/presentation/views/widgets/profile_addresses_section.dart';
import 'package:makanak/features/profile/presentation/views/widgets/profile_header_section.dart';
import 'package:makanak/shared/widgets/app_snack_bar.dart';

class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key});

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {
  @override
  void initState() {
    super.initState();
    context.read<AddressCubit>().fetchAddresses(forceRefresh: true);
  }

  void _showError(String message) {
    AppSnackBar.show(
      context: context,
      message: message,
      badgeText: MaterialLocalizations.of(context).closeButtonTooltip,
      backgroundColor: const Color(0xffD85B5B),
      onBadgeTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppResponsive.all(context, AppSpacing.screenEdge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileHeaderSection(),
            Gap(10),
            Expanded(child: ProfileAddressesSection(onError: _showError)),
            const Gap(70),
          ],
        ),
      ),
    );
  }
}
