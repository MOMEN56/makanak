import 'package:flutter/material.dart';
import 'package:makanak/features/shops/presentation/widgets/shops_list_view_body.dart';

class ShopsListView extends StatelessWidget {
  const ShopsListView({super.key});
  static const String routeName = 'shops_list';
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ShopsListViewBody());
  }
}
