import 'package:equatable/equatable.dart';

class AddressFormDraft extends Equatable {
  const AddressFormDraft({
    this.addressName = '',
    this.phone = '',
    this.floor = '',
    this.building = '',
    this.apartment = '',
    this.notes = '',
  });

  final String addressName;
  final String phone;
  final String floor;
  final String building;
  final String apartment;
  final String notes;

  @override
  List<Object?> get props => [
    addressName,
    phone,
    floor,
    building,
    apartment,
    notes,
  ];
}
