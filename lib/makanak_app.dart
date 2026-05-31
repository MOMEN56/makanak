import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:makanak/core/routing/app_router.dart';
import 'package:makanak/core/services/services.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_navigator_key.dart';
import 'package:makanak/core/utils/app_route_tracker.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/app_remote_config/data/data_sources/app_remote_config_local_data_source.dart';
import 'package:makanak/features/app_remote_config/data/data_sources/app_remote_config_remote_data_source.dart';
import 'package:makanak/features/app_remote_config/data/repos/app_remote_config_repo_impl.dart';
import 'package:makanak/features/app_remote_config/presentation/manager/app_remote_config_cubit/app_remote_config_cubit.dart';
import 'package:makanak/features/app_remote_config/presentation/manager/app_remote_config_cubit/app_remote_config_state.dart';
import 'package:makanak/features/app_remote_config/presentation/views/app_remote_config_gate_view.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_state.dart';
import 'package:makanak/features/auth/presentation/views/auth_gate_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

class MakanakApp extends StatefulWidget {
  const MakanakApp({super.key});

  @override
  State<MakanakApp> createState() => _MakanakAppState();
}

class _MakanakAppState extends State<MakanakApp> {
  late final AppRemoteConfigCubit _appRemoteConfigCubit;
  StreamSubscription<AppRemoteConfigState>? _startupRemoteConfigSubscription;
  bool _hasReleasedFirstFrame = false;

  @override
  void initState() {
    super.initState();
    _appRemoteConfigCubit = AppRemoteConfigCubit(
      AppRemoteConfigRepoImpl(
        AppRemoteConfigRemoteDataSource(getIt<SupabaseClient>()),
        const AppRemoteConfigLocalDataSource(),
      ),
    );
    _startupRemoteConfigSubscription = _appRemoteConfigCubit.stream.listen(
      _handleStartupRemoteConfigState,
    );
    unawaited(_appRemoteConfigCubit.checkAccessOnce());
  }

  @override
  void dispose() {
    _startupRemoteConfigSubscription?.cancel();
    _releaseFirstFrameIfNeeded();
    _appRemoteConfigCubit.close();
    super.dispose();
  }

  void _handleStartupRemoteConfigState(AppRemoteConfigState state) {
    if (state is! AppRemoteConfigResolved) return;
    _releaseFirstFrameIfNeeded();
  }

  void _releaseFirstFrameIfNeeded() {
    if (_hasReleasedFirstFrame) return;

    _hasReleasedFirstFrame = true;
    WidgetsBinding.instance.allowFirstFrame();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>()..initialize(),
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: _shouldReturnToAuthGate,
        listener: (context, state) {
          final pushNotificationService = getIt<PushNotificationService>();

          if (state is AuthUnauthenticated && !state.hasMessage) {
            pushNotificationService.resetNavigationReadiness();
            unawaited(resetAuthenticatedSessionState());
          }

          appNavigatorKey.currentState?.popUntil((route) => route.isFirst);

          if (state is AuthAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              unawaited(pushNotificationService.markNavigationReady());
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

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
                systemStatusBarContrastEnforced: false,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarDividerColor: Colors.transparent,
                systemNavigationBarIconBrightness: Brightness.dark,
                systemNavigationBarContrastEnforced: false,
              ),
              child: Stack(
                children: [
                  gatedChild,
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: MediaQuery.paddingOf(context).top,
                    child: const IgnorePointer(
                      child: ColoredBox(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
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
