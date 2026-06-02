import 'package:flutter_test/flutter_test.dart';
import 'package:makanak/core/data/data_sources/address_local_data_source.dart';
import 'package:makanak/core/models/user_address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const dataSource = AddressLocalDataSource();
  const firstAddress = UserAddressModel(
    id: 'address-1',
    title: 'Home',
    phone: '01000000000',
    details: 'Building 10, Floor 2, Apartment 5',
    notes: 'Leave it with security',
    isDefault: true,
  );
  const secondAddress = UserAddressModel(
    id: 'address-2',
    title: 'Work',
    phone: '01111111111',
    details: 'Building 7, Floor 4, Apartment 12',
    notes: '',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AddressLocalDataSource', () {
    test('saves and loads stored addresses for the same user', () async {
      await dataSource.saveStoredAddresses(
        userId: 'user-1',
        addresses: const [firstAddress, secondAddress],
      );

      final storedAddresses = await dataSource.loadStoredAddresses(
        userId: 'user-1',
      );

      expect(storedAddresses, const [firstAddress, secondAddress]);
    });

    test('keeps each user addresses isolated', () async {
      await dataSource.saveStoredAddresses(
        userId: 'user-1',
        addresses: const [firstAddress],
      );
      await dataSource.saveStoredAddresses(
        userId: 'user-2',
        addresses: const [secondAddress],
      );

      final firstUserAddresses = await dataSource.loadStoredAddresses(
        userId: 'user-1',
      );
      final secondUserAddresses = await dataSource.loadStoredAddresses(
        userId: 'user-2',
      );

      expect(firstUserAddresses, const [firstAddress]);
      expect(secondUserAddresses, const [secondAddress]);
    });

    test(
      'clears invalid stored data instead of keeping corrupted json',
      () async {
        SharedPreferences.setMockInitialValues({
          'user_addresses_user-1': '{"invalid": true}',
        });

        final storedAddresses = await dataSource.loadStoredAddresses(
          userId: 'user-1',
        );
        final prefs = await SharedPreferences.getInstance();

        expect(storedAddresses, isEmpty);
        expect(prefs.getString('user_addresses_user-1'), isNull);
      },
    );
  });
}
