import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.color,
    required this.size,
    this.quantity = 1,
  });

  final Product product;
  final String color;
  final String size;
  final int quantity;

  String get key => '${product.id}::$color::$size';

  double get lineTotal => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      color: color,
      size: size,
      quantity: quantity ?? this.quantity,
    );
  }
}
