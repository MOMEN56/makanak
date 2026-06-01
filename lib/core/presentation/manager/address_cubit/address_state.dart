import 'package:equatable/equatable.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/models/address_form_draft_model.dart';
import 'package:makanak/core/models/user_address_model.dart';

sealed class AddressState extends Equatable {
  const AddressState({
    this.addresses = const [],
    this.selectedAddressIndex = 0,
    this.draft = const AddressFormDraft(),
  });

  final List<UserAddressModel> addresses;
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

  final List<UserAddressModel> loadedAddresses;

  @override
  List<Object?> get props => [...super.props, loadedAddresses];
}

class AddressError extends AddressState {
  const AddressError(
    this.failure, {
    super.addresses,
    super.selectedAddressIndex,
    super.draft,
  });

  final Failure failure;

  String get message => failure.message;
  bool get isNetworkFailure => failure.isNetwork;

  @override
  List<Object?> get props => [...super.props, failure];
}
