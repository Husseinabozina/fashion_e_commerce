import 'dart:async';

import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/search_products.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class SearchState {
  const SearchState();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchReady extends SearchState {
  const SearchReady({
    required this.criteria,
    required this.products,
    required this.categories,
    required this.brands,
  });

  final ProductSearchCriteria criteria;
  final List<Product> products;
  final List<String> categories;
  final List<String> brands;
}

final class SearchFailure extends SearchState {
  const SearchFailure(this.message);

  final String message;
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._searchProducts) : super(const SearchLoading());

  final SearchProducts _searchProducts;
  Timer? _debounce;
  List<String> _categories = const <String>[];
  List<String> _brands = const <String>[];
  ProductSearchCriteria _criteria = const ProductSearchCriteria();

  Future<void> load([
    ProductSearchCriteria initialCriteria = const ProductSearchCriteria(),
  ]) async {
    emit(const SearchLoading());
    _criteria = initialCriteria;

    try {
      final allProducts =
          await _searchProducts(const ProductSearchCriteria());
      _categories =
          allProducts.map((product) => product.category).toSet().toList()
            ..sort();
      _brands = allProducts.map((product) => product.brand).toSet().toList()
        ..sort();
      final products = await _searchProducts(initialCriteria);

      emit(
        SearchReady(
          criteria: _criteria,
          products: products,
          categories: _categories,
          brands: _brands,
        ),
      );
    } catch (_) {
      emit(const SearchFailure('Search could not be loaded.'));
    }
  }

  void updateQuery(String query) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 280),
      () => _apply(
        ProductSearchCriteria(
          query: query,
          category: _criteria.category,
          brand: _criteria.brand,
          sort: _criteria.sort,
        ),
      ),
    );
  }

  Future<void> setCategory(String? category) {
    return _apply(
      ProductSearchCriteria(
        query: _criteria.query,
        category: category,
        brand: _criteria.brand,
        sort: _criteria.sort,
      ),
    );
  }

  Future<void> setBrand(String? brand) {
    return _apply(
      ProductSearchCriteria(
        query: _criteria.query,
        category: _criteria.category,
        brand: brand,
        sort: _criteria.sort,
      ),
    );
  }

  Future<void> setSort(ProductSort sort) {
    return _apply(
      ProductSearchCriteria(
        query: _criteria.query,
        category: _criteria.category,
        brand: _criteria.brand,
        sort: sort,
      ),
    );
  }

  Future<void> clearFilters() {
    return _apply(
      ProductSearchCriteria(
        query: _criteria.query,
        sort: _criteria.sort,
      ),
    );
  }

  Future<void> _apply(ProductSearchCriteria criteria) async {
    _criteria = criteria;

    try {
      final products = await _searchProducts(criteria);
      emit(
        SearchReady(
          criteria: criteria,
          products: products,
          categories: _categories,
          brands: _brands,
        ),
      );
    } catch (_) {
      emit(const SearchFailure('Search could not be updated.'));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
