import 'dart:convert';

import 'package:makanak/core/models/user_address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressLocalDataSource {
  const AddressLocalDataSource();

  static const String _storageKeyPrefix = 'user_addresses_';

  Future<List<UserAddressModel>> loadStoredAddresses({
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final rawAddresses = prefs.getString(_storageKey(userId));
    if (rawAddresses == null || rawAddresses.isEmpty) return [];

    try {
      final decoded = jsonDecode(rawAddresses);
      if (decoded is! List) {
        await clearStoredAddresses(userId: userId);
        return [];
      }

      return decoded.map((item) {
        if (item is! Map) {
          throw const FormatException('Invalid address data.');
        }

        return UserAddressModel.fromStoredJson(Map<String, dynamic>.from(item));
      }).toList();
    } catch (_) {
      await clearStoredAddresses(userId: userId);
      return [];
    }
  }

  Future<void> saveStoredAddresses({
    required String userId,
    required List<UserAddressModel> addresses,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _storageKey(userId);
    if (addresses.isEmpty) {
      await prefs.remove(key);
      return;
    }

    final data = addresses.map((address) => address.toStoredJson()).toList();
    await prefs.setString(key, jsonEncode(data));
  }

  Future<void> clearStoredAddresses({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey(userId));
  }

  String _storageKey(String userId) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'User id cannot be empty.');
    }

    return '$_storageKeyPrefix$normalizedUserId';
  }
}
