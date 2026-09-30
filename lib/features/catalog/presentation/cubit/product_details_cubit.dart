import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_product_details.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class ProductDetailsState {
  const ProductDetailsState();
}

final class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

final class ProductDetailsReady extends ProductDetailsState {
  const ProductDetailsReady({
    required this.product,
    this.selectedColor,
    this.selectedSize,
  });

  final Product product;
  final String? selectedColor;
  final String? selectedSize;

  ProductDetailsReady copyWith({
    String? selectedColor,
    String? selectedSize,
  }) {
    return ProductDetailsReady(
      product: product,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }
}

final class ProductDetailsFailure extends ProductDetailsState {
  const ProductDetailsFailure(this.message);

  final String message;
}

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._getProductDetails)
      : super(const ProductDetailsLoading());

  final GetProductDetails _getProductDetails;

  Future<void> load(String id) async {
    emit(const ProductDetailsLoading());

    try {
      final product = await _getProductDetails(id);
      emit(
        ProductDetailsReady(
          product: product,
          selectedColor: product.colors.isEmpty ? null : product.colors.first,
        ),
      );
    } catch (_) {
      emit(const ProductDetailsFailure('Product could not be loaded.'));
    }
  }

  void selectColor(String color) {
    final current = state;
    if (current is! ProductDetailsReady) return;

    emit(current.copyWith(selectedColor: color));
  }

  void selectSize(String size) {
    final current = state;
    if (current is! ProductDetailsReady) return;

    emit(current.copyWith(selectedSize: size));
  }
}
