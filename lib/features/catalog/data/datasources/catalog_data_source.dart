import 'package:fashion_e_commerce/features/catalog/data/models/product_model.dart';

abstract interface class CatalogDataSource {
  Future<List<ProductModel>> fetchProducts();

  Future<List<String>> fetchCategories();
}
