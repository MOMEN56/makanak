import 'package:makanak/core/services/supabase_remote_data_source.dart';
import 'package:makanak/core/utils/address_form_validator.dart';

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
    final normalizedPhone = AddressFormValidator.normalizeDigits(phoneNumber);
    final data = await guardedRequest(
      () => client.rpc(
        'add_user_address',
        params: {
          'p_street': street.trim(),
          'p_floor': floor.trim(),
          'p_building_number': building.trim(),
          'p_apartment_number': apartmentNumber.trim(),
          'p_address_notes': notes.trim(),
          'p_phone_number': normalizedPhone,
        },
      ),
      operation: 'addUserAddress',
      log: true,
    );

    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> fetchUserAddresses() async {
    final data = await guardedRequest(
      () => client.rpc('fetch_user_addresses'),
      operation: 'fetchUserAddresses',
    );
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> setDefaultUserAddress(String addressId) async {
    final data = await guardedRequest(
      () => client.rpc(
        'set_default_user_address',
        params: {'p_address_id': addressId},
      ),
      operation: 'setDefaultUserAddress',
    );

    return Map<String, dynamic>.from(data as Map);
  }
}
