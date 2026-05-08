import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_state.dart';
import 'package:makanak/features/auth/presentation/views/sign_up_view.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_form_validators.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_form_state_builder.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_google_button.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_message_view.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_primary_button.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_scaffold.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_text_form_field.dart';

class SignInViewBody extends StatefulWidget {
  const SignInViewBody({super.key});

  @override
  State<SignInViewBody> createState() => _SignInViewBodyState();
}

class _SignInViewBodyState extends State<SignInViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthFormStateBuilder(
      builder: (context, authState) {
        final authCubit = authState.authCubit;
        final isLoading = authState.isLoading;
        final loadingOperation = authState.loadingOperation;
        final messageState = authState.messageState;

        return AuthScaffold(
          title: AppStrings.authSignInTitle,
          subtitle: AppStrings.authSignInSubtitle,
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.authSignInFormTitle,
                  textAlign: TextAlign.center,
                  style: TextStyles.bold24.copyWith(
                    color: AppColors.shopNameColor,
                    height: 1.2,
                  ),
                ),
                const Gap(10),
                Text(
                  AppStrings.authSignInFormSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyles.regular14.copyWith(
                    color: AppColors.shopCategoryColor,
                  ),
                ),
                AuthMessageView(messageState: messageState),
                const Gap(22),
                AuthTextFormField(
                  controller: _emailController,
                  label: AppStrings.authEmail,
                  hint: AppStrings.authEmailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  prefixIcon: const Icon(
                    Icons.mail_outline_rounded,
                    color: AppColors.primaryColor,
                  ),
                  validator: validateAuthEmail,
                  onChanged: (_) => authCubit.clearMessage(),
                ),
                const Gap(14),
                AuthTextFormField(
                  controller: _passwordController,
                  label: AppStrings.authPassword,
                  hint: AppStrings.authPasswordHint,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.primaryColor,
                  ),
                  suffixIcon: IconButton(
                    onPressed:
                        isLoading
                            ? null
                            : () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                  validator: validateAuthPassword,
                  onChanged: (_) => authCubit.clearMessage(),
                ),
                const Gap(22),
                AuthPrimaryButton(
                  label: AppStrings.authSignInButton,
                  isLoading: loadingOperation == AuthLoadingOperation.signIn,
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            if (_formKey.currentState?.validate() != true) {
                              return;
                            }

                            FocusScope.of(context).unfocus();
                            authCubit.signInWithEmailPassword(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
                          },
                ),
                const Gap(14),
                AuthGoogleButton(
                  isLoading: loadingOperation == AuthLoadingOperation.google,
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            FocusScope.of(context).unfocus();
                            authCubit.signInWithGoogle();
                          },
                ),
                const Gap(22),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        AppStrings.authHaveNoAccount,
                        style: TextStyles.regular14.copyWith(
                          color: AppColors.shopCategoryColor,
                        ),
                      ),
                      TextButton(
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(SignUpView.routeName);
                                },
                        child: const Text(AppStrings.authCreateAccountLink),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
