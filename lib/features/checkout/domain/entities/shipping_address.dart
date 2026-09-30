class ShippingAddress {
  const ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.city,
    required this.area,
    required this.street,
    required this.building,
    this.notes = '',
  });

  final String fullName;
  final String phone;
  final String city;
  final String area;
  final String street;
  final String building;
  final String notes;

  String get compactLabel => '$street, $area, $city';
}
