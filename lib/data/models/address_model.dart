// lib/data/models/address_model.dart
class AddressModel {
  final String name;
  final String phone;
  final String addressLine;
  final String city;
  final String district;
  final String ward;
  final String? note;

  AddressModel({
    required this.name,
    required this.phone,
    required this.addressLine,
    required this.city,
    required this.district,
    required this.ward,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'addressLine': addressLine,
      'city': city,
      'district': district,
      'ward': ward,
      'note': note,
    };
  }
}