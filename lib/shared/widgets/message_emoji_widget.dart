import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class MessageEmojiWidget extends StatelessWidget {
  const MessageEmojiWidget({super.key, required this.image, this.text});

  static const double _maxImageSize = 220;
  static const double _minImageSize = 96;

  final String image;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final message = text?.trim();

    final mediaQuery = MediaQuery.of(context);
    final usableScreenHeight =
        mediaQuery.size.height -
        mediaQuery.viewInsets.bottom -
        mediaQuery.padding.vertical;
    final imageSize = (usableScreenHeight * 0.35)
        .clamp(_minImageSize, _maxImageSize)
        .toDouble();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              image,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
            ),
            if (message != null && message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyles.bold16.copyWith(color: Colors.black),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
