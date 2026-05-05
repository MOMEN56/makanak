import 'package:equatable/equatable.dart';

class ShopEntity extends Equatable {
  const ShopEntity({
    this.id,
    this.ownerId,
    required this.name,
    this.logoUrl,
    required this.category,
    this.isActive = true,
    this.isVisible = true,
    this.isOpen = true,
    this.workingHours = '',
  });

  final String? id;
  final String? ownerId;
  final String name;
  final String? logoUrl;
  final String category;
  final bool isActive;
  final bool isVisible;
  final bool isOpen;
  final String workingHours;

  String get imageUrl => logoUrl ?? '';

  @override
  List<Object?> get props => [
    id,
    ownerId,
    name,
    logoUrl,
    category,
    isActive,
    isVisible,
    isOpen,
    workingHours,
  ];
}
