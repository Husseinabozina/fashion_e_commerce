import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';

class HomeCatalog {
  const HomeCatalog({
    required this.heroProduct,
    required this.newArrivals,
    required this.categories,
  });

  final Product heroProduct;
  final List<Product> newArrivals;
  final List<String> categories;
}
