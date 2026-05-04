import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_state.dart';
import 'package:makanak/features/auth/presentation/views/sign_in_view.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_form_state_builder.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_google_button.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_message_view.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_primary_button.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_scaffold.dart';
import 'package:makanak/features/auth/presentation/views/widgets/sign_up_form_fields.dart';

class SignUpViewBody extends StatefulWidget {
  const SignUpViewBody({super.key});

  @override
  State<SignUpViewBody> createState() => _SignUpViewBodyState();
}

class _SignUpViewBodyState extends State<SignUpViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          title: 'أنشئ حسابك في مكانك',
          subtitle:
              'أنشئ حسابًا جديدًا لحفظ بياناتك والدخول السريع إلى تجربة تسوق عربية سهلة.',
          showBackButton: true,
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'حساب جديد',
                  textAlign: TextAlign.center,
                  style: TextStyles.bold24.copyWith(
                    color: AppColors.shopNameColor,
                    height: 1.2,
                  ),
                ),
                AuthMessageView(messageState: messageState),
                const Gap(22),
                SignUpFormFields(
                  fullNameController: _fullNameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  enabled: !isLoading,
                  obscurePassword: _obscurePassword,
                  obscureConfirmPassword: _obscureConfirmPassword,
                  onTogglePassword: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  onToggleConfirmPassword: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  onChanged: (_) => authCubit.clearMessage(),
                ),
                const Gap(22),
                AuthPrimaryButton(
                  label: 'إنشاء الحساب',
                  isLoading: loadingOperation == AuthLoadingOperation.signUp,
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            if (_formKey.currentState?.validate() != true) {
                              return;
                            }

                            FocusScope.of(context).unfocus();
                            authCubit.signUpWithEmailPassword(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                              fullName: _fullNameController.text.trim(),
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
                        'عندك حساب بالفعل؟',
                        style: TextStyles.regular14.copyWith(
                          color: AppColors.shopCategoryColor,
                        ),
                      ),
                      TextButton(
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  } else {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      SignInView.routeName,
                                      (route) => false,
                                    );
                                  }
                                },
                        child: const Text('تسجيل الدخول'),
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
