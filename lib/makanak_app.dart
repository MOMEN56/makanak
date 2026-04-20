import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:makanak/core/helper_fun/on_generate_route.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/shops/presentation/views/shops_view.dart';

class MakanakApp extends StatelessWidget {
  const MakanakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مكانك',
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
            statusBarColor: AppColors.greyBackground,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: AppColors.greyBackground,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: ColoredBox(
            color: AppColors.greyBackground,
            child: SafeArea(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
      initialRoute: ShopsView.routeName,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
