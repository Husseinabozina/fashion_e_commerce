import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.brand,
    required super.name,
    required super.price,
    required super.imageUrl,
    required super.colors,
    super.previousPrice,
    super.isNew,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      brand: map['brand'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num? ?? 0).toDouble(),
      previousPrice: (map['previousPrice'] as num?)?.toDouble(),
      imageUrl: map['imageUrl'] as String? ?? '',
      colors: List<String>.from(map['colors'] as List? ?? const <String>[]),
      isNew: map['isNew'] as bool? ?? false,
    );
  }
}
