import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_responsive.dart';

const double _productsGridBaseMaxCrossAxisExtent = 180;
const double _productsGridBaseSpacing = 14;
const double _productsGridChildAspectRatio = 0.68;

SliverGridDelegate buildProductsGridDelegate(BuildContext context) {
  final spacing = AppResponsive.spacing(context, _productsGridBaseSpacing);

  return SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: AppResponsive.width(
      context,
      _productsGridBaseMaxCrossAxisExtent,
    ),
    crossAxisSpacing: spacing,
    mainAxisSpacing: spacing,
    childAspectRatio: _productsGridChildAspectRatio,
  );
}
