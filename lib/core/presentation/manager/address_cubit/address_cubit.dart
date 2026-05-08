import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/domain/repos/address_repository.dart';
import 'package:makanak/core/models/address_form_draft_model.dart';
import 'package:makanak/core/models/confirming_order_address_model.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_state.dart';
import 'package:makanak/core/utils/address_form_validator.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit(this._addressRepository) : super(const AddressInitial());

  final AddressRepository _addressRepository;

  Future<void> checkSavedAddresses() async {
    emit(_loadingFromState());
    final result = await _addressRepository.fetchUserAddresses();
    if (isClosed) return;

    result.fold(
      (failure) => emit(_errorFromState(failure.message)),
      _emitAddressState,
    );
  }

  Future<void> fetchAddresses({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        state is AddressesLoaded &&
        state.addresses.isNotEmpty) {
      _emitAddressesLoaded(state.addresses);
      return;
    }

    emit(_loadingFromState());
    final result = await _addressRepository.fetchUserAddresses();
    if (isClosed) return;

    result.fold((failure) => emit(_errorFromState(failure.message)), (
      addresses,
    ) {
      _emitAddressesLoaded(addresses);
    });
  }

  Future<void> saveAddress({
    required String street,
    required String floor,
    required String building,
    required String apartmentNumber,
    String notes = '',
    required String phoneNumber,
  }) async {
    emit(_loadingFromState());
    final result = await _addressRepository.saveAddress(
      street: street,
      floor: floor,
      building: building,
      apartmentNumber: apartmentNumber,
      notes: notes,
      phoneNumber: phoneNumber,
    );
    if (isClosed) return;

    result.fold((failure) => emit(_errorFromState(failure.message)), (address) {
      final updatedAddresses = [
        ...state.addresses,
        if (!state.addresses.any((item) => item.id == address.id)) address,
      ];
      final savedAddressIndex = updatedAddresses.indexWhere(
        (item) => item.id == address.id,
      );
      _emitAddressesLoaded(
        updatedAddresses,
        selectedAddressIndex:
            savedAddressIndex < 0
                ? state.selectedAddressIndex
                : savedAddressIndex,
      );
    });
  }

  Future<bool> setDefaultAddress(int index) async {
    if (index < 0 || index >= state.addresses.length) return false;

    final address = state.addresses[index];
    if (address.isDefault) {
      selectAddress(index);
      return true;
    }

    emit(_loadingFromState());
    final result = await _addressRepository.setDefaultAddress(address.id);
    if (isClosed) return false;

    return result.fold(
      (failure) {
        emit(_errorFromState(failure.message));
        return false;
      },
      (_) {
        final updatedAddresses =
            state.addresses
                .map(
                  (item) => ConfirmingOrderAddressModel(
                    id: item.id,
                    title: item.title,
                    phone: item.phone,
                    details: item.details,
                    notes: item.notes,
                    isDefault: item.id == address.id,
                  ),
                )
                .toList();
        _emitAddressesLoaded(updatedAddresses, selectedAddressIndex: index);
        return true;
      },
    );
  }

  void selectAddress(int index) {
    if (index < 0 || index >= state.addresses.length) return;
    _emitAddressesLoaded(state.addresses, selectedAddressIndex: index);
  }

  void reset() {
    emit(const AddressInitial());
  }

  void saveDraft({
    required String addressName,
    required String phone,
    required String floor,
    required String building,
    required String apartment,
    required String notes,
  }) {
    emit(
      AddressInitial(
        addresses: state.addresses,
        selectedAddressIndex: _validatedAddressIndex(
          state.selectedAddressIndex,
          state.addresses,
        ),
        draft: AddressFormDraft(
          addressName: addressName,
          phone: AddressFormValidator.normalizeDigits(phone),
          floor: floor,
          building: building,
          apartment: apartment,
          notes: notes,
        ),
      ),
    );
  }

  AddressLoading _loadingFromState() {
    return AddressLoading(
      addresses: state.addresses,
      selectedAddressIndex: _validatedAddressIndex(
        state.selectedAddressIndex,
        state.addresses,
      ),
      draft: state.draft,
    );
  }

  AddressError _errorFromState(String message) {
    return AddressError(
      message,
      addresses: state.addresses,
      selectedAddressIndex: _validatedAddressIndex(
        state.selectedAddressIndex,
        state.addresses,
      ),
      draft: state.draft,
    );
  }

  void _emitAddressState(List<ConfirmingOrderAddressModel> addresses) {
    emit(
      AddressChecked(
        addresses.isNotEmpty,
        addresses: addresses,
        selectedAddressIndex: _defaultAddressIndex(addresses),
        draft: state.draft,
      ),
    );
  }

  void _emitAddressesLoaded(
    List<ConfirmingOrderAddressModel> addresses, {
    int? selectedAddressIndex,
  }) {
    emit(
      AddressesLoaded(
        addresses,
        selectedAddressIndex: _validatedAddressIndex(
          selectedAddressIndex ?? _defaultAddressIndex(addresses),
          addresses,
        ),
        draft: state.draft,
      ),
    );
  }

  int _defaultAddressIndex(List<ConfirmingOrderAddressModel> addresses) {
    if (addresses.isEmpty) return 0;
    final defaultIndex = addresses.indexWhere((address) => address.isDefault);
    return defaultIndex < 0 ? 0 : defaultIndex;
  }

  int _validatedAddressIndex(
    int selectedAddressIndex,
    List<ConfirmingOrderAddressModel> addresses,
  ) {
    if (addresses.isEmpty) return 0;
    if (selectedAddressIndex < 0 || selectedAddressIndex >= addresses.length) {
      return _defaultAddressIndex(addresses);
    }
    return selectedAddressIndex;
  }
}
