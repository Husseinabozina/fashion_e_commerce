import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/search_products.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class CatalogBrowseState {
  const CatalogBrowseState();
}

final class CatalogBrowseLoading extends CatalogBrowseState {
  const CatalogBrowseLoading();
}

final class CatalogBrowseLoaded extends CatalogBrowseState {
  const CatalogBrowseLoaded(this.products);

  final List<Product> products;

  List<String> get categories =>
      (products.map((product) => product.category).toSet().toList()..sort());

  List<String> get brands =>
      (products.map((product) => product.brand).toSet().toList()..sort());
}

final class CatalogBrowseFailure extends CatalogBrowseState {
  const CatalogBrowseFailure(this.message);

  final String message;
}

class CatalogBrowseCubit extends Cubit<CatalogBrowseState> {
  CatalogBrowseCubit(this._searchProducts)
      : super(const CatalogBrowseLoading());

  final SearchProducts _searchProducts;

  Future<void> load() async {
    emit(const CatalogBrowseLoading());

    try {
      emit(
        CatalogBrowseLoaded(
          await _searchProducts(
            const ProductSearchCriteria(
              sort: ProductSort.newest,
            ),
          ),
        ),
      );
    } catch (_) {
      emit(const CatalogBrowseFailure('Catalog could not be loaded.'));
    }
  }
}
