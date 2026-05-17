import 'package:makanak/core/services/supabase_remote_data_source.dart';
import 'package:makanak/core/utils/address_form_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressRemoteDataSource extends SupabaseRemoteDataSource {
  const AddressRemoteDataSource(super.client);

  Future<Map<String, dynamic>> addUserAddress({
    required String street,
    required String floor,
    required String building,
    required String apartmentNumber,
    String notes = '',
    required String phoneNumber,
  }) async {
    try {
      final normalizedPhone = AddressFormValidator.normalizeDigits(phoneNumber);
      final data = await client.rpc(
        'add_user_address',
        params: {
          'p_street': street.trim(),
          'p_floor': floor.trim(),
          'p_building_number': building.trim(),
          'p_apartment_number': apartmentNumber.trim(),
          'p_address_notes': notes.trim(),
          'p_phone_number': normalizedPhone,
        },
      );

      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (error) {
      throw databaseException(error, operation: 'addUserAddress', log: true);
    } catch (error, stackTrace) {
      throw unexpectedDatabaseException(
        operation: 'addUserAddress',
        error: error,
        stackTrace: stackTrace,
        log: true,
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserAddresses() async {
    try {
      final data = await client.rpc('fetch_user_addresses');
      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (error) {
      throw databaseException(error);
    } catch (_) {
      throw unexpectedDatabaseException();
    }
  }

  Future<Map<String, dynamic>> setDefaultUserAddress(String addressId) async {
    try {
      final data = await client.rpc(
        'set_default_user_address',
        params: {'p_address_id': addressId},
      );

      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (error) {
      throw databaseException(error);
    } catch (_) {
      throw unexpectedDatabaseException();
    }
  }
}
