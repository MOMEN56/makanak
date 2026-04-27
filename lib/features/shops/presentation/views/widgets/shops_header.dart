import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_state.dart';
import 'package:makanak/shared/widgets/search_text_field.dart';

class ShopsHeader extends StatelessWidget {
  const ShopsHeader({super.key, this.onSearchChanged});

  final ValueChanged<String>? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'نفسك في إيه؟',
              style: TextStyles.extraBold30.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
            const Gap(5),
            Align(
              alignment: Alignment.center,
              child: BlocBuilder<AuthCubit, AuthState>(
                buildWhen:
                    (previous, current) =>
                        (previous is AuthLoading) != (current is AuthLoading),
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return Tooltip(
                    message: 'تسجيل الخروج',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap:
                          isLoading
                              ? null
                              : () {
                                context.read<AuthCubit>().signOut();
                              },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.shopCategoryIconBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child:
                              isLoading
                                  ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                  : const Icon(
                                    Icons.logout_rounded,
                                    size: 22.5,
                                    color: AppColors.shopCategoryIconColor,
                                  ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const Gap(32),
        SearchTextField(
          hintText:
              '\u0627\u0628\u062d\u062b \u0639\u0646 \u0627\u0644\u0645\u0643\u0627\u0646 \u0627\u0644\u0644\u064a \u0646\u0641\u0633\u0643 \u0641\u064a\u0647..',
          onChanged: onSearchChanged,
        ),
        const Gap(32),
      ],
    );
  }
}
