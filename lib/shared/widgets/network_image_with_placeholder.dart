import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';

class NetworkImageWithPlaceholder extends StatelessWidget {
  const NetworkImageWithPlaceholder({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.cacheWidth,
    this.cacheHeight,
    this.filterQuality = FilterQuality.low,
    this.placeholderIcon = Icons.image_not_supported_outlined,
    this.placeholderColor = AppColors.white,
    this.iconColor = AppColors.lightGrey,
    this.borderRadius,
  });

  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final int? cacheWidth;
  final int? cacheHeight;
  final FilterQuality filterQuality;
  final IconData placeholderIcon;
  final Color placeholderColor;
  final Color iconColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image =
        imageUrl.isEmpty
            ? _ImagePlaceholder(
              height: height,
              width: width,
              icon: placeholderIcon,
              color: placeholderColor,
              iconColor: iconColor,
            )
            : CachedNetworkImage(
              imageUrl: imageUrl,
              height: height,
              width: width,
              fit: fit,
              memCacheWidth: cacheWidth,
              memCacheHeight: cacheHeight,
              maxWidthDiskCache: cacheWidth,
              maxHeightDiskCache: cacheHeight,
              filterQuality: filterQuality,
              placeholder: (_, __) {
                return _ImagePlaceholder(
                  height: height,
                  width: width,
                  icon: placeholderIcon,
                  color: placeholderColor,
                  iconColor: iconColor,
                );
              },
              errorWidget: (_, __, ___) {
                return _ImagePlaceholder(
                  height: height,
                  width: width,
                  icon: placeholderIcon,
                  color: placeholderColor,
                  iconColor: iconColor,
                );
              },
            );

    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.icon,
    required this.color,
    required this.iconColor,
    this.height,
    this.width,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: SizedBox(
        height: height,
        width: width,
        child: Center(child: Icon(icon, color: iconColor)),
      ),
    );
  }
}
