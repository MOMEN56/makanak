import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/shared/widgets/network_image_with_placeholder.dart';

class ProductDetailsImage extends StatelessWidget {
  const ProductDetailsImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: NetworkImageWithPlaceholder(
        imageUrl: imageUrl,
        height: 260,
        width: double.infinity,
        cacheWidth: 800,
        placeholderColor: AppColors.white,
      ),
    );
  }
}
