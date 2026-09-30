import 'package:fashion_e_commerce/features/catalog/data/datasources/catalog_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/data/models/product_model.dart';

class DemoCatalogDataSource implements CatalogDataSource {
  @override
  Future<List<String>> fetchCategories() async {
    return const <String>[
      'Sneakers',
      'Hoodies',
      'Jackets',
      'T-Shirts',
      'Bags',
    ];
  }

  @override
  Future<List<ProductModel>> fetchProducts() async {
    return const <ProductModel>[
      ProductModel(
        id: 'nb-9060',
        brand: 'NEW BALANCE',
        name: '9060',
        price: 3499,
        previousPrice: 3999,
        imageUrl:
            'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=900&q=80',
        colors: <String>['Black', 'Grey', 'Sand'],
        sizes: <String>['40', '41', '42', '43', '44'],
        fit: 'Regular fit',
        description:
            'A layered street runner with an oversized sole and everyday cushioning.',
        isNew: true,
      ),
      ProductModel(
        id: 'nike-air',
        brand: 'NIKE',
        name: 'Air Max Essential',
        price: 2999,
        imageUrl:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80',
        colors: <String>['Red', 'White'],
        sizes: <String>['40', '41', '42', '43'],
        fit: 'True to size',
        description:
            'A clean everyday sneaker with visible cushioning and a bold color story.',
        isNew: true,
      ),
      ProductModel(
        id: 'street-01',
        brand: 'NOVA SELECT',
        name: 'Street Runner 01',
        price: 2799,
        imageUrl:
            'https://images.unsplash.com/photo-1608231387042-66d1773070a5?auto=format&fit=crop&w=900&q=80',
        colors: <String>['Black', 'White'],
        sizes: <String>['41', '42', '43', '44'],
        fit: 'Regular fit',
        description:
            'Minimal street runner selected for daily rotation and clean styling.',
      ),
      ProductModel(
        id: 'street-02',
        brand: 'NOVA SELECT',
        name: 'Court Low 02',
        price: 3199,
        imageUrl:
            'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?auto=format&fit=crop&w=900&q=80',
        colors: <String>['White', 'Grey'],
        sizes: <String>['39', '40', '41', '42', '43'],
        fit: 'Slightly narrow',
        description:
            'Low-profile court styling with a clean upper and versatile neutral finish.',
      ),
    ];
  }
}
