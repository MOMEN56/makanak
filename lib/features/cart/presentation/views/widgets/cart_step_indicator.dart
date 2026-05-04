import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class CartStepIndicator extends StatelessWidget {
  const CartStepIndicator({
    super.key,
    required this.currentStep,
    this.primaryColor = AppColors.primaryColor,
    this.showAddressStep = true,
  });

  final int currentStep;
  final Color primaryColor;
  final bool showAddressStep;

  static const _steps = [
    _CartStepData(icon: Icons.shopping_cart_outlined, label: AppStrings.cart),
    _CartStepData(icon: Icons.location_on_outlined, label: AppStrings.address),
    _CartStepData(
      icon: Icons.check_circle_outline_rounded,
      label: AppStrings.confirmation,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleIndexes = showAddressStep ? [0, 1, 2] : [0, 2];

    return Row(
      children: [
        for (var index = 0; index < visibleIndexes.length; index++) ...[
          _buildStep(visibleIndexes[index]),
          if (index != visibleIndexes.length - 1)
            _StepLine(
              isActive: visibleIndexes[index] < currentStep,
              primaryColor: primaryColor,
            ),
        ],
      ],
    );
  }

  Widget _buildStep(int stepIndex) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: _StepItem(
          data: _steps[stepIndex],
          isActive: stepIndex <= currentStep,
          isCurrent: stepIndex == currentStep,
          primaryColor: primaryColor,
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.data,
    required this.isActive,
    required this.isCurrent,
    required this.primaryColor,
  });

  final _CartStepData data;
  final bool isActive;
  final bool isCurrent;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? primaryColor : AppColors.lightGrey;
    final darkerPrimaryColor = AppColors.darkerShade(primaryColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color:
                isActive ? primaryColor : primaryColor.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent ? darkerPrimaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(
            data.icon,
            color: isActive ? AppColors.white : AppColors.lightGrey,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.medium12.copyWith(color: color),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.isActive, required this.primaryColor});

  final bool isActive;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isActive ? primaryColor : AppColors.searchFieldBackground,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const SizedBox(height: 3),
        ),
      ),
    );
  }
}

class _CartStepData {
  const _CartStepData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
