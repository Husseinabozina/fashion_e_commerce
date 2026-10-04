import 'package:cloud_firestore/cloud_firestore.dart';
import 'catalog_data_source.dart';
import '../models/product_model.dart';

class FirestoreCatalogDataSource implements CatalogDataSource {
  FirestoreCatalogDataSource(this.db);
  final FirebaseFirestore db;
  @override
  Future<List<ProductModel>> fetchProducts() async {
    final result = await db.collection('products').get();
    final docs = result.docs.toList()
      ..sort((a, b) => (a.data()['catalogOrder'] as num? ?? 0)
          .compareTo(b.data()['catalogOrder'] as num? ?? 0));
    return docs.map((doc) => ProductModel.fromMap(doc.id, doc.data())).toList();
  }

  @override
  Future<List<String>> fetchCategories() async {
    final result = await db.collection('catalog').doc('settings').get();
    return List<String>.from(result.data()?['categories'] as List? ?? const []);
  }
}
