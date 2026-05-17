import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';

class CartCubitRegistry {
  CartCubitRegistry(this._createCartCubit);

  final CartCubit Function(String userId) _createCartCubit;
  final Map<String, CartCubit> _activeCubits = {};
  bool _isDisposing = false;

  CartCubit forUser(String userId) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'User id cannot be empty.');
    }
    if (_isDisposing) {
      throw StateError(
        'CartCubitRegistry is disposing and cannot create new cubits.',
      );
    }

    return _activeCubits.putIfAbsent(
      normalizedUserId,
      () => _createCartCubit(normalizedUserId),
    );
  }

  Future<void> disposeForUser(String userId) async {
    if (_isDisposing) {
      throw StateError(
        'CartCubitRegistry is disposing and cannot dispose a single cubit.',
      );
    }

    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'User id cannot be empty.');
    }

    final cubit = _activeCubits.remove(normalizedUserId);
    if (cubit != null) {
      await cubit.close();
    }
  }

  Future<void> disposeAll() async {
    if (_isDisposing) return;
    _isDisposing = true;

    final cubits = _activeCubits.values.toList(growable: false);
    _activeCubits.clear();

    try {
      for (final cubit in cubits) {
        await cubit.close();
      }
    } finally {
      _isDisposing = false;
    }
  }
}
