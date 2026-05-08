import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/features/auth/domain/entities/profile_entity.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_state.dart';
import 'package:makanak/features/profile/presentation/views/widgets/profile_actions_sheet.dart';
import 'package:makanak/features/profile/presentation/views/widgets/profile_header.dart';

class ProfileHeaderSection extends StatefulWidget {
  const ProfileHeaderSection({super.key});

  @override
  State<ProfileHeaderSection> createState() => _ProfileHeaderSectionState();
}

class _ProfileHeaderSectionState extends State<ProfileHeaderSection> {
  ProfileEntity? _lastProfile;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen:
          (previous, current) =>
              previous.runtimeType != current.runtimeType ||
              previous is AuthAuthenticated ||
              current is AuthAuthenticated ||
              previous is AuthLoading ||
              current is AuthLoading,
      builder: (context, state) {
        final profile = _resolveProfile(state);
        final isSigningOut =
            state is AuthLoading &&
            state.operation == AuthLoadingOperation.signOut;

        return ProfileHeader(
          profile: profile,
          isSigningOut: isSigningOut,
          onSignOutTap: isSigningOut ? null : () => _openActionsSheet(context),
        );
      },
    );
  }

  void _openActionsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (bottomSheetContext) => ProfileActionsSheet(
            onSignOut: () {
              Navigator.of(bottomSheetContext).pop();
              context.read<AuthCubit>().signOut();
            },
            onGoToShopsList: () {
              Navigator.of(bottomSheetContext).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
    );
  }

  ProfileEntity? _resolveProfile(AuthState state) {
    if (state is AuthAuthenticated) {
      _lastProfile = state.profile;
    }

    return _lastProfile;
  }
}
