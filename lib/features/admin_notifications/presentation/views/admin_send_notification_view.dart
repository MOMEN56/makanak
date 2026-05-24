import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/admin_notifications/presentation/manager/admin_send_notification_cubit/admin_send_notification_cubit.dart';
import 'package:makanak/features/admin_notifications/presentation/manager/admin_send_notification_cubit/admin_send_notification_state.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_state.dart';
import 'package:makanak/shared/widgets/app_snack_bar.dart';
import 'package:makanak/shared/widgets/custom_button.dart';

class AdminSendNotificationView extends StatelessWidget {
  const AdminSendNotificationView({super.key});

  static const String routeName = 'admin-send-notification';

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(body: AdminSendNotificationViewBody()),
    );
  }
}

class AdminSendNotificationViewBody extends StatefulWidget {
  const AdminSendNotificationViewBody({super.key});

  @override
  State<AdminSendNotificationViewBody> createState() =>
      _AdminSendNotificationViewBodyState();
}

class _AdminSendNotificationViewBodyState
    extends State<AdminSendNotificationViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _userIdController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    return BlocListener<AdminSendNotificationCubit, AdminSendNotificationState>(
      listener: (context, state) {
        if (state.status == AdminSendNotificationStatus.success &&
            state.message != null) {
          _titleController.clear();
          _bodyController.clear();
          _userIdController.clear();
          _showSnackBar(
            message: state.message!,
            backgroundColor: AppColors.primaryColor,
            badgeText: MaterialLocalizations.of(context).okButtonLabel,
          );
          context.read<AdminSendNotificationCubit>().clearFeedback();
        }

        if (state.status == AdminSendNotificationStatus.failure &&
            state.message != null) {
          _showSnackBar(
            message: state.message!,
            backgroundColor: const Color(0xffD85B5B),
            badgeText: MaterialLocalizations.of(context).closeButtonTooltip,
          );
          context.read<AdminSendNotificationCubit>().clearFeedback();
        }
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: AppResponsive.all(context, AppSpacing.screenEdge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderSection(
                onBackPressed: () => Navigator.of(context).maybePop(),
              ),
              Gap(AppResponsive.spacing(context, 16)),
              if (authState is AuthLoading)
                const Center(child: CircularProgressIndicator())
              else if (!_hasAdminAccess(authState))
                const _AccessDeniedCard()
              else
                _NotificationForm(
                  formKey: _formKey,
                  titleController: _titleController,
                  bodyController: _bodyController,
                  userIdController: _userIdController,
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasAdminAccess(AuthState authState) {
    if (authState is! AuthAuthenticated) {
      return false;
    }

    return authState.profile.role.trim().toLowerCase() == 'admin';
  }

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
    required String badgeText,
  }) {
    AppSnackBar.show(
      context: context,
      message: message,
      badgeText: badgeText,
      backgroundColor: backgroundColor,
      onBadgeTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppResponsive.all(context, 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppResponsive.radius(context, 24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkColor.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 18),
            spreadRadius: -18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onBackPressed,
              style: IconButton.styleFrom(backgroundColor: AppColors.white),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          Gap(AppResponsive.spacing(context, 6)),
          Text(
            AppStrings.adminNotificationViewTitle,
            style: TextStyles.bold24.copyWith(
              color: AppColors.primaryDarkColor,
              height: 1.2,
            ),
          ),
          Gap(AppResponsive.spacing(context, 8)),
          Text(
            AppStrings.adminNotificationViewSubtitle,
            style: TextStyles.regular14.copyWith(
              color: AppColors.shopCategoryColor,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessDeniedCard extends StatelessWidget {
  const _AccessDeniedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppResponsive.all(context, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppResponsive.radius(context, 24)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: AppResponsive.width(context, 34),
            color: AppColors.primaryDarkColor,
          ),
          Gap(AppResponsive.spacing(context, 12)),
          Text(
            AppStrings.adminNotificationAccessDenied,
            textAlign: TextAlign.center,
            style: TextStyles.bold16.copyWith(color: AppColors.shopNameColor),
          ),
          Gap(AppResponsive.spacing(context, 8)),
          Text(
            AppStrings.adminNotificationAccessHint,
            textAlign: TextAlign.center,
            style: TextStyles.regular14.copyWith(
              color: AppColors.shopCategoryColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationForm extends StatelessWidget {
  const _NotificationForm({
    required this.formKey,
    required this.titleController,
    required this.bodyController,
    required this.userIdController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final TextEditingController userIdController;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminSendNotificationCubit>().state;
    final cubit = context.read<AdminSendNotificationCubit>();

    return Container(
      padding: AppResponsive.all(context, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppResponsive.radius(context, 24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkColor.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 18),
            spreadRadius: -18,
          ),
        ],
      ),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.adminNotificationFormTitle,
              style: TextStyles.bold20.copyWith(color: AppColors.shopNameColor),
            ),
            Gap(AppResponsive.spacing(context, 6)),
            Text(
              AppStrings.adminNotificationFormSubtitle,
              style: TextStyles.regular14.copyWith(
                color: AppColors.shopCategoryColor,
                height: 1.6,
              ),
            ),
            Gap(AppResponsive.spacing(context, 18)),
            _AdminNotificationTextField(
              controller: titleController,
              label: AppStrings.adminNotificationTitleLabel,
              hint: AppStrings.adminNotificationTitleHint,
              textInputAction: TextInputAction.next,
              enabled: !state.isLoading,
              prefixIcon: const Icon(
                Icons.campaign_outlined,
                color: AppColors.primaryColor,
              ),
              validator: _validateTitle,
              onChanged: (_) => cubit.clearFeedback(),
            ),
            Gap(AppResponsive.spacing(context, 14)),
            _AdminNotificationTextField(
              controller: bodyController,
              label: AppStrings.adminNotificationBodyLabel,
              hint: AppStrings.adminNotificationBodyHint,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              enabled: !state.isLoading,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 56),
                child: Icon(Icons.notes_rounded, color: AppColors.primaryColor),
              ),
              validator: _validateBody,
              onChanged: (_) => cubit.clearFeedback(),
            ),
            Gap(AppResponsive.spacing(context, 14)),
            _AdminNotificationTextField(
              controller: userIdController,
              label: AppStrings.adminNotificationUserIdLabel,
              hint: AppStrings.adminNotificationUserIdHint,
              textInputAction: TextInputAction.done,
              enabled: !state.isLoading,
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.primaryColor,
              ),
              onChanged: (_) => cubit.clearFeedback(),
            ),
            Gap(AppResponsive.spacing(context, 18)),
            AbsorbPointer(
              absorbing: state.isLoading,
              child: Opacity(
                opacity: state.isLoading ? 0.75 : 1,
                child: CustomButton(
                  hint:
                      state.isLoading
                          ? AppStrings.adminNotificationSending
                          : AppStrings.adminNotificationSendButton,
                  onTap: () {
                    if (formKey.currentState?.validate() != true) {
                      return;
                    }

                    FocusScope.of(context).unfocus();
                    cubit.sendNotification(
                      title: titleController.text,
                      body: bodyController.text,
                      userId: userIdController.text,
                    );
                  },
                  preventRapidTaps: true,
                  icon:
                      state.isLoading
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                          : const Icon(
                            Icons.send_rounded,
                            color: AppColors.white,
                          ),
                  hasShadowEffect: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.adminNotificationTitleRequired;
    }

    return null;
  }

  String? _validateBody(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.adminNotificationBodyRequired;
    }

    return null;
  }
}

class _AdminNotificationTextField extends StatelessWidget {
  const _AdminNotificationTextField({
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.prefixIcon,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final Widget? prefixIcon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      minLines: maxLines > 1 ? maxLines : 1,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      style: TextStyles.medium16.copyWith(color: AppColors.shopNameColor),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintText: hint,
        hintStyle: TextStyles.regular14.copyWith(color: AppColors.lightGrey),
        labelStyle: TextStyles.regular14.copyWith(
          color: AppColors.shopCategoryColor,
        ),
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: AppColors.greyBackground.withValues(alpha: 0.9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        prefixIcon: prefixIcon,
        border: _border(),
        enabledBorder: _border(color: Colors.transparent),
        focusedBorder: _border(color: AppColors.primaryColor),
        errorBorder: _border(color: const Color(0xffD85B5B)),
        focusedErrorBorder: _border(color: const Color(0xffD85B5B)),
      ),
    );
  }

  OutlineInputBorder _border({Color color = AppColors.searchFieldBackground}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color),
    );
  }
}
