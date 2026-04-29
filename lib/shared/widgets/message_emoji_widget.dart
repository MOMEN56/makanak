import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class MessageEmojiWidget extends StatelessWidget {
  const MessageEmojiWidget({super.key, required this.image, this.text});

  final String image;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final message = text?.trim();

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize =
            constraints.maxHeight < 320 ? constraints.maxHeight * 0.45 : 220.0;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
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
            ),
          ),
        );
      },
    );
  }
}
