import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/views/cart_view.dart';
import 'package:makanak/features/cart/presentation/views/widgets/add_user_address_view_body.dart';
import 'package:makanak/features/cart/presentation/views/widgets/confirming_order_view_body.dart';
import 'package:makanak/features/cart/presentation/views/widgets/submit_order_view_body.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

class CartNavigationTab extends StatefulWidget {
  const CartNavigationTab({super.key, this.shopModel, this.onBack});

  final ShopModel? shopModel;
  final VoidCallback? onBack;

  @override
  State<CartNavigationTab> createState() => _CartNavigationTabState();
}

class _CartNavigationTabState extends State<CartNavigationTab> {
  _CartFlowStep _currentStep = _CartFlowStep.cart;
  bool _showAddressStep = false;
  CartViewArguments? _cartArguments;

  @override
  void initState() {
    super.initState();
    _cartArguments = _initialCartArguments;
  }

  CartViewArguments? get _initialCartArguments {
    final shopModel = widget.shopModel;
    if (shopModel == null) {
      return null;
    }

    return CartViewArguments(
      product: null,
      quantity: 1,
      primaryColor: AppColors.primaryColor,
      shopModel: shopModel,
    );
  }

  void _openNextCartStep(
    CartViewArguments? routeArguments,
    bool hasSavedAddress,
  ) {
    setState(() {
      _cartArguments = routeArguments ?? _cartArguments ?? _initialCartArguments;
      _showAddressStep = !hasSavedAddress;
      _currentStep =
          hasSavedAddress ? _CartFlowStep.confirmingOrder : _CartFlowStep.addAddress;
    });
  }

  void _openConfirmingOrder(CartViewArguments? routeArguments) {
    setState(() {
      _cartArguments = routeArguments ?? _cartArguments ?? _initialCartArguments;
      _showAddressStep = true;
      _currentStep = _CartFlowStep.confirmingOrder;
    });
  }

  void _openSubmitOrder(CartViewArguments? routeArguments) {
    setState(() {
      _cartArguments = routeArguments ?? _cartArguments ?? _initialCartArguments;
      _currentStep = _CartFlowStep.submitOrder;
    });
  }

  void _goBackToCart() {
    setState(() {
      _currentStep = _CartFlowStep.cart;
      _showAddressStep = false;
    });
  }

  void _goBackFromConfirmingOrder() {
    setState(() {
      _currentStep = _showAddressStep ? _CartFlowStep.addAddress : _CartFlowStep.cart;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_currentStep) {
      _CartFlowStep.cart => CartView(
        cartArguments: _cartArguments,
        bottomContentPadding:
            AppSpacing.buttonBottomExtraGapWithLiquidGlassNavigation,
        onBack: widget.onBack,
        onContinueRequested: _openNextCartStep,
      ),
      _CartFlowStep.addAddress => AddUserAddressViewBody(
        cartArguments: _cartArguments,
        onBack: _goBackToCart,
        onContinueRequested: _openConfirmingOrder,
      ),
      _CartFlowStep.confirmingOrder => ConfirmingOrderViewBody(
        cartArguments: _cartArguments,
        showAddressStep: _showAddressStep,
        onBack: _goBackFromConfirmingOrder,
        onOrderSubmitted: _openSubmitOrder,
      ),
      _CartFlowStep.submitOrder => SubmitOrderViewBody(
        cartArguments: _cartArguments,
      ),
    };
  }
}

enum _CartFlowStep { cart, addAddress, confirmingOrder, submitOrder }
