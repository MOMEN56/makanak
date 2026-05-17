import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';

class CartCubitRegistry {
  CartCubitRegistry(this._createCartCubit);

  final CartCubit Function(String userId) _createCartCubit;
  final Map<String, CartCubit> _activeCubits = {};

  CartCubit forUser(String userId) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'User id cannot be empty.');
    }

    return _activeCubits.putIfAbsent(
      normalizedUserId,
      () => _createCartCubit(normalizedUserId),
    );
  }

  Future<void> disposeAll() async {
    final cubits = _activeCubits.values.toList(growable: false);
    _activeCubits.clear();

    for (final cubit in cubits) {
      await cubit.close();
    }
  }
}
