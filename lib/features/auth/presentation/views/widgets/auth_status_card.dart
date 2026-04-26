import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class AuthStatusCard extends StatelessWidget {
  const AuthStatusCard({
    super.key,
    required this.message,
    this.isError = false,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isError ? const Color(0xffFDEDED) : const Color(0xffEEF5FF);
    final foregroundColor =
        isError ? const Color(0xffB53B3B) : const Color(0xff1E5EB8);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            color: foregroundColor,
            size: 20,
          ),
          const Gap(10),
          Expanded(
            child: Text(
              message,
              style: TextStyles.regular14.copyWith(
                color: foregroundColor,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
