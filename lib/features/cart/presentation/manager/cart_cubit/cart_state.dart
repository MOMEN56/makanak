import 'package:equatable/equatable.dart';
import 'package:makanak/features/cart/data/models/address_form_draft_model.dart';
import 'package:makanak/features/cart/data/models/confirming_order_address_model.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';

sealed class CartState extends Equatable {
  const CartState({
    this.product,
    this.quantity = 1,
    this.addresses = const [],
    this.selectedAddressIndex = 0,
    this.draft = const AddressFormDraft(),
    this.shippingPrice = 35,
  });

  final ProductModel? product;
  final int quantity;
  final List<ConfirmingOrderAddressModel> addresses;
  final int selectedAddressIndex;
  final AddressFormDraft draft;
  final int shippingPrice;

  bool get hasSavedAddress => addresses.isNotEmpty;
  int get itemsSubtotal => product == null ? 0 : product!.price * quantity;
  int get orderTotal => itemsSubtotal + shippingPrice;

  @override
  List<Object?> get props => [
    product,
    quantity,
    addresses,
    selectedAddressIndex,
    draft,
    shippingPrice,
  ];
}

class CartInitial extends CartState {
  const CartInitial({
    super.product,
    super.quantity,
    super.addresses,
    super.selectedAddressIndex,
    super.draft,
    super.shippingPrice,
  });
}

class CartLoading extends CartState {
  const CartLoading({
    super.product,
    super.quantity,
    super.addresses,
    super.selectedAddressIndex,
    super.draft,
    super.shippingPrice,
  });
}

class CartAddressChecked extends CartState {
  const CartAddressChecked(
    this.hasSavedAddressValue, {
    super.product,
    super.quantity,
    super.addresses,
    super.selectedAddressIndex,
    super.draft,
    super.shippingPrice,
  });

  final bool hasSavedAddressValue;

  @override
  bool get hasSavedAddress => hasSavedAddressValue;

  @override
  List<Object?> get props => [...super.props, hasSavedAddressValue];
}

class CartAddressesLoaded extends CartState {
  const CartAddressesLoaded(
    this.loadedAddresses, {
    super.product,
    super.quantity,
    super.selectedAddressIndex,
    super.draft,
    super.shippingPrice,
  }) : super(addresses: loadedAddresses);

  final List<ConfirmingOrderAddressModel> loadedAddresses;

  @override
  List<Object?> get props => [...super.props, loadedAddresses];
}

class CartOrderSubmitted extends CartState {
  const CartOrderSubmitted({
    super.product,
    super.quantity,
    super.addresses,
    super.selectedAddressIndex,
    super.draft,
    super.shippingPrice,
  });
}

class CartError extends CartState {
  const CartError(
    this.message, {
    super.product,
    super.quantity,
    super.addresses,
    super.selectedAddressIndex,
    super.draft,
    super.shippingPrice,
  });

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}
