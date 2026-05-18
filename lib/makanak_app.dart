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
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_state.dart';
import 'package:makanak/features/auth/presentation/views/auth_gate_view.dart';

class MakanakApp extends StatelessWidget {
  const MakanakApp({super.key});

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
                  child ?? const SizedBox.shrink(),
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
