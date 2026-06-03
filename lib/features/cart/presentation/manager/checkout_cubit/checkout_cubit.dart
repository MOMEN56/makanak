import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/bloc/safe_emit_mixin.dart';
import 'package:makanak/features/cart/data/services/cart_local_storage.dart';
import 'package:makanak/features/cart/domain/entities/create_order_item.dart';
import 'package:makanak/features/cart/domain/repos/cart_repository.dart';
import 'package:makanak/features/cart/presentation/manager/checkout_cubit/checkout_state.dart';
import 'package:makanak/features/cart/services/cart_availability_service.dart';
import 'package:makanak/features/shops/data/repos/shops_repo.dart';

class CheckoutCubit extends Cubit<CheckoutState>
    with SafeEmitMixin<CheckoutState> {
  CheckoutCubit(
    this._cartRepository,
    this._cartAvailabilityService,
    this._shopsRepo,
  ) : super(const CheckoutInitial());

  final CartRepository _cartRepository;
  final CartAvailabilityService _cartAvailabilityService;
  final ShopsRepo _shopsRepo;
  bool _isCreatingOrder = false;
  int _failureId = 0;

  Future<String?> networkMessageBeforeCheckout({
    required List<CartLocalData> cartItems,
    String? shopId,
  }) async {
    final resolvedShopId = _cartAvailabilityService.resolveShopId(
      items: cartItems,
      shopId: shopId,
    );
    if (resolvedShopId == null || resolvedShopId.isEmpty) {
      return null;
    }

    final result = await _shopsRepo.fetchShopById(resolvedShopId);
    return result.fold(
      (failure) => failure.isNetwork ? failure.message : null,
      (_) => null,
    );
  }

  Future<void> createOrder({
    required String addressId,
    required List<CartLocalData> cartItems,
    required int fallbackShippingPrice,
  }) async {
    if (_isCreatingOrder) return;

    _isCreatingOrder = true;
    try {
      var itemsToSubmit = List<CartLocalData>.of(cartItems);
      final normalizedAddressId = addressId.trim();

      if (itemsToSubmit.isEmpty) {
        emit(_failure(AppStrings.invalidProduct));
        return;
      }

      final shopId = _cartAvailabilityService.resolveShopId(
        items: itemsToSubmit,
      );
      if (shopId == null) {
        emit(_failure(AppStrings.invalidProduct));
        return;
      }

      if (normalizedAddressId.isEmpty) {
        emit(_failure(AppStrings.invalidAddress));
        return;
      }

      final shopValidation = await _cartAvailabilityService.validateShop(
        shopId,
        fetchFailureMessage: AppStrings.cartAvailabilityCheckFailed,
      );
      if (!shopValidation.isValid) {
        safeEmit(_failure(shopValidation.message));
        return;
      }

      final preSubmitSync = await _cartAvailabilityService.syncItems(
        sourceItems: itemsToSubmit,
        shopId: shopId,
      );
      if (preSubmitSync.syncFailed) {
        safeEmit(
          _failure(
            preSubmitSync.failureMessage ??
                AppStrings.cartAvailabilityCheckFailed,
          ),
        );
        return;
      }

      if (preSubmitSync.didFetchLatestProducts) {
        itemsToSubmit = preSubmitSync.availableItems;
        if (preSubmitSync.removedItems.isNotEmpty) {
          safeEmit(
            _failure(
              _cartAvailabilityService.messageForRemovedItems(
                preSubmitSync.removedItems,
              ),
              syncedItems: itemsToSubmit,
              syncedShopId: preSubmitSync.shopId,
            ),
          );
          return;
        }
      }

      final validatedShopId = _cartAvailabilityService.resolveShopId(
        items: itemsToSubmit,
      );
      final orderItems = _buildOrderItems(itemsToSubmit);
      final hasMixedShops =
          validatedShopId == null ||
          itemsToSubmit.any(
            (item) => item.product.shopId.trim() != validatedShopId,
          );

      if (validatedShopId == null ||
          hasMixedShops ||
          orderItems.length != itemsToSubmit.length) {
        safeEmit(_failure(AppStrings.invalidProduct));
        return;
      }

      safeEmit(const CheckoutLoading());
      final submittedShippingPrice = _shippingPriceFor(
        itemsToSubmit,
        fallbackShippingPrice: fallbackShippingPrice,
      );
      final result = await _cartRepository.createOrder(
        shopId: validatedShopId,
        addressId: normalizedAddressId,
        shippingPrice: submittedShippingPrice,
        items: orderItems,
      );

      await result.fold<Future<void>>(
        (failure) async {
          if (_isShopStateFailureMessage(failure.message)) {
            safeEmit(_failure(failure.message));
            return;
          }

          final postFailureSync = await _cartAvailabilityService.syncItems(
            sourceItems: itemsToSubmit,
            shopId: validatedShopId,
          );
          if (postFailureSync.syncFailed) {
            safeEmit(
              _failure(
                postFailureSync.failureMessage ??
                    AppStrings.cartAvailabilityCheckFailed,
              ),
            );
            return;
          }

          List<CartLocalData>? syncedItems;
          String? syncedShopId;

          if (postFailureSync.didFetchLatestProducts) {
            final syncedCartItems = postFailureSync.availableItems;
            final didCartChange = _didCartItemsChange(
              itemsToSubmit,
              syncedCartItems,
            );
            itemsToSubmit = syncedCartItems;

            if (postFailureSync.removedItems.isNotEmpty) {
              safeEmit(
                _failure(
                  _cartAvailabilityService.messageForRemovedItems(
                    postFailureSync.removedItems,
                  ),
                  syncedItems: itemsToSubmit,
                  syncedShopId: postFailureSync.shopId,
                ),
              );
              return;
            }

            if (didCartChange) {
              syncedItems = syncedCartItems;
              syncedShopId = postFailureSync.shopId;
            }
          }

          safeEmit(
            _failure(
              failure.message,
              syncedItems: syncedItems,
              syncedShopId: syncedShopId,
            ),
          );
        },
        (_) async {
          safeEmit(
            CheckoutSubmitted(
              shopId: validatedShopId,
              shippingPrice: submittedShippingPrice,
            ),
          );
        },
      );
    } finally {
      _isCreatingOrder = false;
    }
  }

  List<CreateOrderItem> _buildOrderItems(List<CartLocalData> items) {
    return items
        .map(
          (item) => CreateOrderItem(
            productId: item.product.id ?? '',
            quantity: item.quantity,
          ),
        )
        .where((item) => item.productId.trim().isNotEmpty)
        .toList(growable: false);
  }

  int _shippingPriceFor(
    List<CartLocalData> items, {
    required int fallbackShippingPrice,
  }) {
    if (items.isEmpty) return fallbackShippingPrice;
    return items.first.shippingPrice;
  }

  bool _isShopStateFailureMessage(String message) {
    return message == AppStrings.shopClosedNow ||
        message == AppStrings.shopUnavailableNow;
  }

  bool _didCartItemsChange(
    List<CartLocalData> previousItems,
    List<CartLocalData> nextItems,
  ) {
    if (previousItems.length != nextItems.length) return true;

    for (var index = 0; index < previousItems.length; index++) {
      final previousItem = previousItems[index];
      final nextItem = nextItems[index];

      if (previousItem.product != nextItem.product ||
          previousItem.quantity != nextItem.quantity ||
          previousItem.shippingPrice != nextItem.shippingPrice) {
        return true;
      }
    }

    return false;
  }

  CheckoutFailure _failure(
    String message, {
    List<CartLocalData>? syncedItems,
    String? syncedShopId,
  }) {
    return CheckoutFailure(
      message,
      failureId: ++_failureId,
      syncedItems: syncedItems,
      syncedShopId: syncedShopId,
    );
  }
}
