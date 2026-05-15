import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/domain/repos/address_repository.dart';
import 'package:makanak/core/models/address_form_draft_model.dart';
import 'package:makanak/core/models/user_address_model.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_state.dart';
import 'package:makanak/core/services/supabase_auth_service.dart';
import 'package:makanak/core/utils/address_form_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AddressCubit extends Cubit<AddressState> {
  AddressCubit(this._addressRepository, this._authService)
    : _activeUserId = _currentUserId(_authService),
      super(const AddressInitial()) {
    _authStateSubscription = _authService.onAuthStateChange.listen(
      _handleAuthStateChange,
    );
  }

  final AddressRepository _addressRepository;
  final SupabaseAuthService _authService;

  StreamSubscription<supa.AuthState>? _authStateSubscription;
  String? _activeUserId;

  Future<void> checkSavedAddresses() async {
    if (!_hasAuthenticatedUser()) return;

    final requestUserId = _activeUserId;
    emit(_loadingFromState());
    final result = await _addressRepository.fetchUserAddresses();
    if (isClosed || !_isActiveUser(requestUserId)) return;

    result.fold(
      (failure) => emit(_errorFromState(failure.message)),
      _emitAddressState,
    );
  }

  Future<void> fetchAddresses({bool forceRefresh = false}) async {
    if (!_hasAuthenticatedUser()) return;

    if (!forceRefresh &&
        state is AddressesLoaded &&
        state.addresses.isNotEmpty) {
      _emitAddressesLoaded(state.addresses);
      return;
    }

    final requestUserId = _activeUserId;
    emit(_loadingFromState());
    final result = await _addressRepository.fetchUserAddresses();
    if (isClosed || !_isActiveUser(requestUserId)) return;

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
    if (!_hasAuthenticatedUser()) return;

    final requestUserId = _activeUserId;
    emit(_loadingFromState());
    final result = await _addressRepository.saveAddress(
      street: street,
      floor: floor,
      building: building,
      apartmentNumber: apartmentNumber,
      notes: notes,
      phoneNumber: phoneNumber,
    );
    if (isClosed || !_isActiveUser(requestUserId)) return;

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
    if (!_hasAuthenticatedUser()) return false;
    if (index < 0 || index >= state.addresses.length) return false;

    final requestUserId = _activeUserId;
    final address = state.addresses[index];
    if (address.isDefault) {
      selectAddress(index);
      return true;
    }

    emit(_loadingFromState());
    final result = await _addressRepository.setDefaultAddress(address.id);
    if (isClosed || !_isActiveUser(requestUserId)) return false;

    return result.fold(
      (failure) {
        emit(_errorFromState(failure.message));
        return false;
      },
      (_) {
        final updatedAddresses =
            state.addresses
                .map(
                  (item) => UserAddressModel(
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
    if (!_hasAuthenticatedUser()) return;
    if (index < 0 || index >= state.addresses.length) return;
    _emitAddressesLoaded(state.addresses, selectedAddressIndex: index);
  }

  void reset() {
    if (isClosed) return;

    _activeUserId = _currentUserId(_authService);
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
    if (!_hasAuthenticatedUser()) return;

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

  void _emitAddressState(List<UserAddressModel> addresses) {
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
    List<UserAddressModel> addresses, {
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

  int _defaultAddressIndex(List<UserAddressModel> addresses) {
    if (addresses.isEmpty) return 0;
    final defaultIndex = addresses.indexWhere((address) => address.isDefault);
    return defaultIndex < 0 ? 0 : defaultIndex;
  }

  int _validatedAddressIndex(
    int selectedAddressIndex,
    List<UserAddressModel> addresses,
  ) {
    if (addresses.isEmpty) return 0;
    if (selectedAddressIndex < 0 || selectedAddressIndex >= addresses.length) {
      return _defaultAddressIndex(addresses);
    }
    return selectedAddressIndex;
  }

  bool _hasAuthenticatedUser() {
    if (isClosed) return false;

    final currentUserId = _currentUserId(_authService);
    if (currentUserId != _activeUserId) {
      _activeUserId = currentUserId;
      emit(const AddressInitial());
    }

    return _activeUserId != null;
  }

  bool _isActiveUser(String? userId) {
    if (userId == null || userId != _activeUserId) return false;
    return userId == _currentUserId(_authService);
  }

  void _handleAuthStateChange(supa.AuthState authState) {
    final userId = _normalizeUserId(authState.session?.user.id);
    if (userId == _activeUserId) return;

    _activeUserId = userId;
    if (!isClosed) emit(const AddressInitial());
  }

  static String? _currentUserId(SupabaseAuthService authService) {
    return _normalizeUserId(authService.currentSession?.user.id);
  }

  static String? _normalizeUserId(String? userId) {
    final normalizedUserId = userId?.trim();
    if (normalizedUserId == null || normalizedUserId.isEmpty) return null;
    return normalizedUserId;
  }

  @override
  Future<void> close() async {
    await _authStateSubscription?.cancel();
    return super.close();
  }
}
