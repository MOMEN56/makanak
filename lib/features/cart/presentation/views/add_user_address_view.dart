import 'package:flutter/material.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/views/widgets/add_user_address_view_body.dart';

class AddUserAddressView extends StatelessWidget {
  const AddUserAddressView({
    super.key,
    this.cartArguments,
    this.returnOnSave = false,
  });

  static const String routeName = 'add_user_address';

  final CartViewArguments? cartArguments;
  final bool returnOnSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AddUserAddressViewBody(
        cartArguments: cartArguments,
        returnOnSave: returnOnSave,
      ),
    );
  }
}
