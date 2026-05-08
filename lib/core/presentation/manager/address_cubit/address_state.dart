import 'package:equatable/equatable.dart';
import 'package:makanak/core/models/address_form_draft_model.dart';
import 'package:makanak/core/models/confirming_order_address_model.dart';

sealed class AddressState extends Equatable {
  const AddressState({
    this.addresses = const [],
    this.selectedAddressIndex = 0,
    this.draft = const AddressFormDraft(),
  });

  final List<ConfirmingOrderAddressModel> addresses;
  final int selectedAddressIndex;
  final AddressFormDraft draft;

  bool get hasSavedAddress => addresses.isNotEmpty;

  @override
  List<Object?> get props => [addresses, selectedAddressIndex, draft];
}

class AddressInitial extends AddressState {
  const AddressInitial({
    super.addresses,
    super.selectedAddressIndex,
    super.draft,
  });
}

class AddressLoading extends AddressState {
  const AddressLoading({
    super.addresses,
    super.selectedAddressIndex,
    super.draft,
  });
}

class AddressChecked extends AddressState {
  const AddressChecked(
    this.hasSavedAddressValue, {
    super.addresses,
    super.selectedAddressIndex,
    super.draft,
  });

  final bool hasSavedAddressValue;

  @override
  bool get hasSavedAddress => hasSavedAddressValue;

  @override
  List<Object?> get props => [...super.props, hasSavedAddressValue];
}

class AddressesLoaded extends AddressState {
  const AddressesLoaded(
    this.loadedAddresses, {
    super.selectedAddressIndex,
    super.draft,
  }) : super(addresses: loadedAddresses);

  final List<ConfirmingOrderAddressModel> loadedAddresses;

  @override
  List<Object?> get props => [...super.props, loadedAddresses];
}

class AddressError extends AddressState {
  const AddressError(
    this.message, {
    super.addresses,
    super.selectedAddressIndex,
    super.draft,
  });

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}
