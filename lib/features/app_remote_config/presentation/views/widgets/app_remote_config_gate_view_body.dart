import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/app_remote_config/app_remote_config_strings.dart';
import 'package:makanak/features/app_remote_config/domain/entities/app_access_result.dart';
import 'package:makanak/features/app_remote_config/presentation/manager/app_remote_config_cubit/app_remote_config_cubit.dart';
import 'package:makanak/features/app_remote_config/presentation/manager/app_remote_config_cubit/app_remote_config_state.dart';
import 'package:makanak/features/app_remote_config/presentation/views/widgets/app_remote_config_blocking_widget.dart';
import 'package:makanak/features/app_remote_config/presentation/views/widgets/app_remote_config_loading_view_body.dart';
import 'package:url_launcher/url_launcher.dart';

class AppRemoteConfigGateViewBody extends StatefulWidget {
  const AppRemoteConfigGateViewBody({super.key, required this.child});

  final Widget child;

  @override
  State<AppRemoteConfigGateViewBody> createState() =>
      _AppRemoteConfigGateViewBodyState();
}

class _AppRemoteConfigGateViewBodyState
    extends State<AppRemoteConfigGateViewBody> {
  bool _isLaunchingForceUpdate = false;
  String? _forceUpdateLaunchError;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppRemoteConfigCubit, AppRemoteConfigState>(
      builder: (BuildContext context, AppRemoteConfigState state) {
        return switch (state) {
          AppRemoteConfigInitial() ||
          AppRemoteConfigLoading() => const AppRemoteConfigLoadingViewBody(),

          AppRemoteConfigResolved(:final result) => switch (result.status) {
            AppAccessStatus.allowed => widget.child,

            AppAccessStatus.maintenance => AppRemoteConfigBlockingWidget(
              title: AppRemoteConfigStrings.maintenanceTitle,
              message:
                  result.message ??
                  AppRemoteConfigStrings.maintenanceFallbackMessage,
              icon: Icons.build_rounded,
              primaryActionLabel: AppRemoteConfigStrings.retry,
              onPrimaryAction: context.read<AppRemoteConfigCubit>().retry,
              primaryActionColor: AppColors.primaryColor,
            ),

            AppAccessStatus.forceUpdate => AppRemoteConfigBlockingWidget(
              title: AppRemoteConfigStrings.forceUpdateTitle,
              message:
                  result.message ??
                  AppRemoteConfigStrings.forceUpdateFallbackMessage,
              icon: Icons.system_update_rounded,
              primaryActionLabel:
                  _isLaunchingForceUpdate
                      ? AppRemoteConfigStrings.openingStore
                      : AppRemoteConfigStrings.updateNow,
              onPrimaryAction:
                  _isLaunchingForceUpdate
                      ? () {}
                      : () => _handleForceUpdate(result),
              errorMessage: _forceUpdateLaunchError,
              primaryActionColor: AppColors.primaryColor,
            ),
          },
        };
      },
    );
  }

  Future<void> _handleForceUpdate(AppAccessResult result) async {
    setState(() {
      _isLaunchingForceUpdate = true;
      _forceUpdateLaunchError = null;
    });

    final bool success = await _launchUpdateUrl(result.updateUrl);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLaunchingForceUpdate = false;
      _forceUpdateLaunchError =
          success ? null : AppRemoteConfigStrings.openStoreError;
    });
  }

  Future<bool> _launchUpdateUrl(String? rawUrl) async {
    final String normalizedUrl = rawUrl?.trim() ?? '';

    if (normalizedUrl.isEmpty) {
      return false;
    }

    final Uri? uri = Uri.tryParse(normalizedUrl);

    if (uri == null) {
      return false;
    }

    if (!_isSupportedUpdateUri(uri)) {
      return false;
    }

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  bool _isSupportedUpdateUri(Uri uri) {
    if (uri.scheme == 'market' || uri.scheme == 'itms-apps') {
      return true;
    }

    return uri.scheme == 'https';
  }
}
