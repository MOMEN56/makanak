import 'package:flutter/material.dart';

class ShopModel {
  const ShopModel({
    required this.imageUrl,
    required this.categoryIcon,
    required this.name,
    required this.category,
  });

  final String imageUrl;
  final IconData categoryIcon;
  final String name;
  final String category;
}
