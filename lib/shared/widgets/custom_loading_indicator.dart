import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({
    super.key,
    this.size = 40,
    this.strokeWidth = 4,
    this.color,
  });

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: size,
        child: CircularProgressIndicator(
          color: color ?? Theme.of(context).primaryColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
