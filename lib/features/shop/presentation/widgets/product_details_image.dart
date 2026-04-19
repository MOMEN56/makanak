import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';

class ProductDetailsImage extends StatelessWidget {
  const ProductDetailsImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: AppColors.white,
        child: Image.network(
          imageUrl,
          height: 260,
          width: double.infinity,
          fit: BoxFit.cover,
          cacheWidth: 800,
          filterQuality: FilterQuality.low,
          errorBuilder: (_, __, ___) {
            return const SizedBox(
              height: 260,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.lightGrey,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
