import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/catalog/data/models/product_model.dart';

abstract final class CartItemMapper {
  static Map<String, dynamic> reference(CartItem item) => {
        'productId': item.product.id,
        'color': item.color,
        'size': item.size,
        'quantity': item.quantity,
      };
  static Map<String, dynamic> snapshot(CartItem item) => {
        ...reference(item),
        'brand': item.product.brand,
        'name': item.product.name,
        'category': item.product.category,
        'price': item.product.price,
        'imageUrl': item.product.imageUrl,
      };
  static CartItem fromSnapshot(Map<String, dynamic> data) => CartItem(
        product: ProductModel.fromMap(data['productId'] as String, data),
        color: data['color'] as String,
        size: data['size'] as String,
        quantity: data['quantity'] as int,
      );
}
