import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/address_form_validator.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/data/models/address_form_draft_model.dart';
import 'package:makanak/features/cart/data/services/cart_local_storage.dart';
import 'package:makanak/features/cart/data/models/confirming_order_address_model.dart';
import 'package:makanak/features/cart/domain/repos/cart_repository.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._cartRepository) : super(const CartInitial());

  final CartRepository _cartRepository;
  bool _hasCheckedAddresses = false;

  Future<void> restoreSavedCart({String? shopId}) async {
    final savedCart = await CartLocalStorage.loadProduct();
    if (savedCart == null || isClosed) return;

    if (shopId != null &&
        shopId.isNotEmpty &&
        savedCart.product.shopId != shopId) {
      await CartLocalStorage.clear();
      return;
    }

    emit(
      CartInitial(
        product: savedCart.product,
        quantity: savedCart.quantity < 1 ? 1 : savedCart.quantity,
        addresses: state.addresses,
        selectedAddressIndex: _validatedAddressIndex(
          state.selectedAddressIndex,
          state.addresses,
        ),
        draft: state.draft,
        shippingPrice: savedCart.shippingPrice,
      ),
    );
  }

  void addProduct(CartViewArguments arguments) {
    final currentProduct = state.product;
    final incomingProduct = arguments.product;
    if (incomingProduct == null) return;

    final currentProductId = currentProduct?.id;
    final incomingProductId = incomingProduct.id;
    final isSameProduct =
        currentProductId != null &&
        currentProductId.isNotEmpty &&
        currentProductId == incomingProductId;
    final updatedQuantity =
        isSameProduct ? state.quantity + arguments.quantity : arguments.quantity;
    final safeQuantity = updatedQuantity < 1 ? 1 : updatedQuantity;

    emit(
      CartInitial(
        product: incomingProduct,
        quantity: safeQuantity,
        addresses: state.addresses,
        selectedAddressIndex: _validatedAddressIndex(
          state.selectedAddressIndex,
          state.addresses,
        ),
        draft: state.draft,
        shippingPrice: arguments.shippingPrice,
      ),
    );

    unawaited(
      CartLocalStorage.saveProduct(
        product: incomingProduct,
        quantity: safeQuantity,
        shippingPrice: arguments.shippingPrice,
      ),
    );
  }

  void initializeCart(CartViewArguments? arguments) {
    if (arguments == null) return;

    final currentProductId = state.product?.id;
    final incomingProductId = arguments.product?.id;
    final isSameInitializedProduct =
        currentProductId != null &&
        currentProductId.isNotEmpty &&
        currentProductId == incomingProductId;

    if (isSameInitializedProduct) {
      emit(
        CartInitial(
          product: state.product,
          quantity: arguments.quantity,
          addresses: state.addresses,
          selectedAddressIndex: _validatedAddressIndex(
            state.selectedAddressIndex,
            state.addresses,
          ),
          draft: state.draft,
          shippingPrice: arguments.shippingPrice,
        ),
      );
      return;
    }

    emit(
      CartInitial(
        product: arguments.product,
        quantity: arguments.quantity,
        addresses: state.addresses,
        selectedAddressIndex: _validatedAddressIndex(
          state.selectedAddressIndex,
          state.addresses,
        ),
        draft: state.draft,
        shippingPrice: arguments.shippingPrice,
      ),
    );
  }

  Future<void> checkSavedAddresses() async {
    if (_hasCheckedAddresses) {
      _emitAddressState(state.addresses);
      return;
    }

    emit(_loadingFromState());
    final result = await _cartRepository.fetchUserAddresses();
    if (isClosed) return;

    result.fold(
      (failure) {
        _hasCheckedAddresses = true;
        emit(_errorFromState(failure.message));
      },
      (addresses) {
        _hasCheckedAddresses = true;
        _emitAddressState(addresses);
      },
    );
  }

  Future<void> fetchAddresses() async {
    if (state.addresses.isNotEmpty) {
      _emitAddressesLoaded(state.addresses);
      return;
    }

    emit(_loadingFromState());
    final result = await _cartRepository.fetchUserAddresses();
    if (isClosed) return;

    result.fold((failure) => emit(_errorFromState(failure.message)), (
      addresses,
    ) {
      _hasCheckedAddresses = true;
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
    final result = await _cartRepository.saveAddress(
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
      _hasCheckedAddresses = true;
      _emitAddressesLoaded(updatedAddresses);
    });
  }

  Future<void> setDefaultAddress(int index) async {
    if (index < 0 || index >= state.addresses.length) return;

    final address = state.addresses[index];
    if (address.isDefault) {
      selectAddress(index);
      return;
    }

    emit(_loadingFromState());
    final result = await _cartRepository.setDefaultAddress(address.id);
    if (isClosed) return;

    result.fold((failure) => emit(_errorFromState(failure.message)), (_) {
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
    });
  }

  Future<void> createOrder() async {
    final product = state.product;
    final productId = product?.id;
    if (product == null || productId == null || productId.isEmpty) {
      emit(_errorFromState(AppStrings.invalidProduct));
      return;
    }

    if (state.addresses.isEmpty) {
      emit(_errorFromState(AppStrings.invalidAddress));
      return;
    }

    final selectedAddressIndex = _validatedAddressIndex(
      state.selectedAddressIndex,
      state.addresses,
    );
    final selectedAddress = state.addresses[selectedAddressIndex];
    emit(_loadingFromState());
    final result = await _cartRepository.createOrder(
      shopId: product.shopId,
      productId: productId,
      addressId: selectedAddress.id,
      quantity: state.quantity,
      itemsTotal: state.itemsSubtotal,
      shippingPrice: state.shippingPrice,
    );
    if (isClosed) return;

    result.fold((failure) => emit(_errorFromState(failure.message)), (_) {
      unawaited(CartLocalStorage.clear());
      emit(
        CartOrderSubmitted(
          product: state.product,
          quantity: state.quantity,
          addresses: state.addresses,
          selectedAddressIndex: selectedAddressIndex,
          draft: const AddressFormDraft(),
          shippingPrice: state.shippingPrice,
        ),
      );
    });
  }

  void updateQuantity(int quantity) {
    final safeQuantity = quantity < 1 ? 1 : quantity;
    emit(
      CartInitial(
        product: state.product,
        quantity: safeQuantity,
        addresses: state.addresses,
        selectedAddressIndex: _validatedAddressIndex(
          state.selectedAddressIndex,
          state.addresses,
        ),
        draft: state.draft,
        shippingPrice: state.shippingPrice,
      ),
    );

    final product = state.product;
    if (product != null) {
      unawaited(
        CartLocalStorage.saveProduct(
          product: product,
          quantity: safeQuantity,
          shippingPrice: state.shippingPrice,
        ),
      );
    }
  }

  void removeItem() {
    emit(
      CartInitial(
        addresses: state.addresses,
        selectedAddressIndex: _validatedAddressIndex(
          state.selectedAddressIndex,
          state.addresses,
        ),
        draft: state.draft,
        shippingPrice: state.shippingPrice,
      ),
    );
    unawaited(CartLocalStorage.clear());
  }

  void clearProductFromOtherShop(String? shopId) {
    if (shopId == null || shopId.isEmpty) return;
    final product = state.product;
    if (product == null || product.shopId == shopId) return;

    removeItem();
  }

  void selectAddress(int index) {
    if (index < 0 || index >= state.addresses.length) return;
    _emitAddressesLoaded(state.addresses, selectedAddressIndex: index);
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
      CartInitial(
        product: state.product,
        quantity: state.quantity,
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
        shippingPrice: state.shippingPrice,
      ),
    );
  }

  CartLoading _loadingFromState() {
    return CartLoading(
      product: state.product,
      quantity: state.quantity,
      addresses: state.addresses,
      selectedAddressIndex: _validatedAddressIndex(
        state.selectedAddressIndex,
        state.addresses,
      ),
      draft: state.draft,
      shippingPrice: state.shippingPrice,
    );
  }

  CartError _errorFromState(String message) {
    return CartError(
      message,
      product: state.product,
      quantity: state.quantity,
      addresses: state.addresses,
      selectedAddressIndex: _validatedAddressIndex(
        state.selectedAddressIndex,
        state.addresses,
      ),
      draft: state.draft,
      shippingPrice: state.shippingPrice,
    );
  }

  void _emitAddressState(List<ConfirmingOrderAddressModel> addresses) {
    emit(
      CartAddressChecked(
        addresses.isNotEmpty,
        product: state.product,
        quantity: state.quantity,
        addresses: addresses,
        selectedAddressIndex: _defaultAddressIndex(addresses),
        draft: state.draft,
        shippingPrice: state.shippingPrice,
      ),
    );
  }

  void _emitAddressesLoaded(
    List<ConfirmingOrderAddressModel> addresses, {
    int? selectedAddressIndex,
  }) {
    emit(
      CartAddressesLoaded(
        addresses,
        product: state.product,
        quantity: state.quantity,
        selectedAddressIndex: _validatedAddressIndex(
          selectedAddressIndex ?? _defaultAddressIndex(addresses),
          addresses,
        ),
        draft: state.draft,
        shippingPrice: state.shippingPrice,
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
