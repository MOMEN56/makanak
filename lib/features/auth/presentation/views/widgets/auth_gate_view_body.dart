import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_state.dart';
import 'package:makanak/features/auth/presentation/views/sign_in_view.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_logo_badge.dart';
import 'package:makanak/features/shops/presentation/views/shops_view.dart';

class AuthGateViewBody extends StatelessWidget {
  const AuthGateViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen:
          (previous, current) => previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        return switch (state) {
          AuthAuthenticated() => const ShopsView(),
          AuthUnauthenticated() => const SignInView(),
          _ => Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AuthLogoBadge(),
                    const Gap(22),
                    Text(
                      'جار تجهيز حسابك',
                      style: TextStyles.bold24.copyWith(
                        color: AppColors.primaryDarkColor,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      'لحظات بسيطة ونوصلك للصفحة المناسبة.',
                      textAlign: TextAlign.center,
                      style: TextStyles.regular14.copyWith(
                        color: AppColors.shopCategoryColor,
                      ),
                    ),
                    const Gap(18),
                    const SizedBox.square(
                      dimension: 30,
                      child: CircularProgressIndicator(strokeWidth: 2.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        };
      },
    );
  }
}
