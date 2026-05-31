import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/shared/widgets/add_address_button.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class EmptyAddresses extends StatelessWidget {
  const EmptyAddresses({super.key, required this.onAddAddress});

  final VoidCallback? onAddAddress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: StateMessage(message: AppStrings.noSavedAddresses),
        ),
        AddAddressButton(onTap: onAddAddress),
      ],
    );
  }
}
