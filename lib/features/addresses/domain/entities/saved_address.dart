import 'package:fashion_e_commerce/features/checkout/domain/entities/shipping_address.dart';

class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.address,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final ShippingAddress address;
  final bool isDefault;

  SavedAddress copyWith({
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id,
      label: label,
      address: address,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
