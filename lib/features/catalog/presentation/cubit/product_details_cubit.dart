import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/add_to_cart.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_product_details.dart';
import 'package:fashion_e_commerce/features/notifications/domain/entities/back_in_stock_subscription.dart';
import 'package:fashion_e_commerce/features/notifications/domain/usecases/subscribe_back_in_stock.dart';
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
    this.subscribedSizes = const <String>{},
  });

  final Product product;
  final String? selectedColor;
  final String? selectedSize;
  final Set<String> subscribedSizes;

  ProductDetailsReady copyWith({
    String? selectedColor,
    String? selectedSize,
    Set<String>? subscribedSizes,
  }) {
    return ProductDetailsReady(
      product: product,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      subscribedSizes: subscribedSizes ?? this.subscribedSizes,
    );
  }
}

final class ProductDetailsFailure extends ProductDetailsState {
  const ProductDetailsFailure(this.message);

  final String message;
}

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(
    this._getProductDetails,
    this._addToCart,
    this._subscribeBackInStock,
  ) : super(const ProductDetailsLoading());

  final GetProductDetails _getProductDetails;
  final AddToCart _addToCart;
  final SubscribeBackInStock _subscribeBackInStock;

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
    if (current is! ProductDetailsReady ||
        !current.product.isSizeAvailable(size)) {
      return;
    }

    emit(current.copyWith(selectedSize: size));
  }

  Future<bool> subscribeForSize(String size) async {
    final current = state;
    if (current is! ProductDetailsReady) return false;

    final color = current.selectedColor;
    if (color == null || current.product.isSizeAvailable(size)) {
      return false;
    }

    await _subscribeBackInStock(
      BackInStockSubscription(
        productId: current.product.id,
        color: color,
        size: size,
      ),
    );

    emit(
      current.copyWith(
        subscribedSizes: <String>{
          ...current.subscribedSizes,
          size,
        },
      ),
    );

    return true;
  }

  Future<bool> addSelectedToCart() async {
    final current = state;
    if (current is! ProductDetailsReady) return false;

    final color = current.selectedColor;
    final size = current.selectedSize;
    if (color == null ||
        size == null ||
        !current.product.isSizeAvailable(size)) {
      return false;
    }

    await _addToCart(
      CartItem(
        product: current.product,
        color: color,
        size: size,
      ),
    );

    return true;
  }
}
