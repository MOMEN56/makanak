import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:makanak/core/deep_linking/deep_link_navigator.dart';
import 'package:makanak/core/deep_linking/deep_link_service.dart';
import 'package:makanak/core/deep_linking/install_referrer_service.dart';
import 'package:makanak/core/routing/app_router.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/core/services/services.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_navigator_key.dart';
import 'package:makanak/core/utils/app_route_tracker.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/app_remote_config/data/data_sources/app_remote_config_local_data_source.dart';
import 'package:makanak/features/app_remote_config/data/data_sources/app_remote_config_remote_data_source.dart';
import 'package:makanak/features/app_remote_config/data/repos/app_remote_config_repo_impl.dart';
import 'package:makanak/features/app_remote_config/presentation/manager/app_remote_config_cubit/app_remote_config_cubit.dart';
import 'package:makanak/features/app_remote_config/presentation/views/app_remote_config_gate_view.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_state.dart';
import 'package:makanak/features/auth/presentation/views/auth_gate_view.dart';
import 'package:makanak/shared/views/release_error_view.dart';
import 'package:makanak/shared/widgets/app_system_ui_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

class MakanakApp extends StatefulWidget {
  const MakanakApp({super.key});

  @override
  State<MakanakApp> createState() => _MakanakAppState();
}

class _MakanakAppState extends State<MakanakApp> {
  late final AppRemoteConfigCubit _appRemoteConfigCubit;
  late final DeepLinkService _deepLinkService;
  late final InstallReferrerService _installReferrerService;
  late final ErrorWidgetBuilder _previousErrorWidgetBuilder;

  @override
  void initState() {
    super.initState();
    _previousErrorWidgetBuilder = ErrorWidget.builder;
    _configureReleaseErrorWidget();
    _deepLinkService = getIt<DeepLinkService>();
    _installReferrerService = getIt<InstallReferrerService>();
    _appRemoteConfigCubit = AppRemoteConfigCubit(
      AppRemoteConfigRepoImpl(
        AppRemoteConfigRemoteDataSource(getIt<SupabaseClient>()),
        const AppRemoteConfigLocalDataSource(),
      ),
    );
    unawaited(_appRemoteConfigCubit.checkAccessOnce());
    unawaited(_deepLinkService.initialize());
    unawaited(_installReferrerService.initialize());
  }

  @override
  void dispose() {
    unawaited(_deepLinkService.dispose());
    _restoreErrorWidgetBuilder();
    _appRemoteConfigCubit.close();
    super.dispose();
  }

  void _configureReleaseErrorWidget() {
    if (!kReleaseMode) return;

    ErrorWidget.builder =
        (details) => ReleaseErrorView(onReturnHome: _returnToHome);
  }

  void _restoreErrorWidgetBuilder() {
    if (!kReleaseMode) return;
    ErrorWidget.builder = _previousErrorWidgetBuilder;
  }

  void _returnToHome() {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushNamedAndRemoveUntil(AuthGateView.routeName, (route) => false);
  }

  Future<void> _handleAuthenticatedNavigation(
    DeepLinkNavigator deepLinkNavigator,
    PushNotificationService pushNotificationService,
  ) async {
    await deepLinkNavigator.openPendingAfterLogin();
    await pushNotificationService.markNavigationReady();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>()..initialize(),
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: _shouldReturnToAuthGate,
        listener: (context, state) {
          final deepLinkNavigator = getIt<DeepLinkNavigator>();
          final pushNotificationService = getIt<PushNotificationService>();

          if (state is AuthUnauthenticated) {
            deepLinkNavigator.resetNavigationReadiness();
          }

          if (state is AuthUnauthenticated && !state.hasMessage) {
            pushNotificationService.resetNavigationReadiness();
            unawaited(resetAuthenticatedSessionState());
          }

          appNavigatorKey.currentState?.popUntil((route) => route.isFirst);

          if (state is AuthAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              unawaited(
                _handleAuthenticatedNavigation(
                  deepLinkNavigator,
                  pushNotificationService,
                ),
              );
            });
          }
        },
        child: MaterialApp(
          navigatorKey: appNavigatorKey,
          navigatorObservers: [appRouteObserver],
          title: AppStrings.appTitle,
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Cairo',
            primaryColor: AppColors.primaryColor,
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: AppColors.primaryColor,
            ),
            scaffoldBackgroundColor: AppColors.greyBackground,
          ),
          builder: (context, child) {
            final gatedChild = BlocProvider.value(
              value: _appRemoteConfigCubit,
              child: AppRemoteConfigGateView(
                child: child ?? const SizedBox.shrink(),
              ),
            );

            return AppSystemUiWrapper(child: gatedChild);
          },
          initialRoute: AuthGateView.routeName,
          onGenerateRoute: onGenerateRoute,
        ),
      ),
    );
  }
}

bool _shouldReturnToAuthGate(AuthState previous, AuthState current) {
  final becameAuthenticated =
      previous is! AuthAuthenticated && current is AuthAuthenticated;
  final becameUnauthenticated =
      previous is! AuthUnauthenticated &&
      current is AuthUnauthenticated &&
      !current.hasMessage;

  return becameAuthenticated || becameUnauthenticated;
}
