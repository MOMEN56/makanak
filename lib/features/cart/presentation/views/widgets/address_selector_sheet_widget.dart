import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/cart/data/models/confirming_order_address_model.dart';
import 'package:makanak/features/cart/presentation/views/widgets/selectable_address_card_widget.dart';
import 'package:makanak/shared/widgets/custom_button.dart';

class AddressSelectorSheet extends StatefulWidget {
  const AddressSelectorSheet({
    super.key,
    required this.addresses,
    required this.selectedIndex,
    required this.onAddressSelected,
    required this.primaryColor,
    required this.onMainAddressSelected,
  });

  final List<ConfirmingOrderAddressModel> addresses;
  final int selectedIndex;
  final ValueChanged<int> onAddressSelected;
  final Color primaryColor;
  final Future<void> Function(int index) onMainAddressSelected;

  @override
  State<AddressSelectorSheet> createState() => _AddressSelectorSheetState();
}

class _AddressSelectorSheetState extends State<AddressSelectorSheet> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _pageController = PageController(
      initialPage: widget.selectedIndex,
      viewportFraction: 0.9,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _setMainAddress(int index) async {
    await widget.onMainAddressSelected(index);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.searchFieldBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const Gap(18),
            Text(
              AppStrings.chooseDeliveryAddress,
              style: TextStyles.bold16.copyWith(color: AppColors.shopNameColor),
            ),
            const Gap(14),
            SizedBox(
              height: 178,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.addresses.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder:
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SelectableAddressCard(
                        address: widget.addresses[index],
                        isSelected: index == widget.selectedIndex,
                        primaryColor: widget.primaryColor,
                        onSetAsMain:
                            widget.addresses[index].isDefault
                                ? null
                                : () => _setMainAddress(index),
                      ),
                    ),
              ),
            ),
            const Gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < widget.addresses.length; index++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: index == _currentIndex ? 22 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color:
                          index == _currentIndex
                              ? widget.primaryColor
                              : AppColors.searchFieldBackground,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
            const Gap(18),
            CustomButton(
              hint: AppStrings.useThisAddress,
              onTap: () => widget.onAddressSelected(_currentIndex),
              color: widget.primaryColor,
              icon: const Icon(
                Icons.check_rounded,
                color: AppColors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
