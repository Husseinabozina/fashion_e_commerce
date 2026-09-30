import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/add_to_cart.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_complete_look.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_product_details.dart';
import 'package:fashion_e_commerce/features/notifications/domain/entities/back_in_stock_subscription.dart';
import 'package:fashion_e_commerce/features/notifications/domain/usecases/subscribe_back_in_stock.dart';
import 'package:fashion_e_commerce/features/reviews/domain/entities/product_review.dart';
import 'package:fashion_e_commerce/features/reviews/domain/usecases/get_product_reviews.dart';
import 'package:fashion_e_commerce/features/reviews/domain/usecases/submit_product_review.dart';
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
    this.lookProducts = const <Product>[],
    this.selectedLookIds = const <String>{},
    this.lookSizes = const <String, String>{},
    this.reviews = const <ProductReview>[],
  });

  final Product product;
  final String? selectedColor;
  final String? selectedSize;
  final Set<String> subscribedSizes;
  final List<Product> lookProducts;
  final Set<String> selectedLookIds;
  final Map<String, String> lookSizes;
  final List<ProductReview> reviews;

  double get lookTotal {
    return lookProducts
        .where((product) => selectedLookIds.contains(product.id))
        .fold<double>(0, (sum, product) => sum + product.price);
  }

  bool get canAddLook {
    if (selectedLookIds.isEmpty) return false;

    return selectedLookIds.every(
      (productId) => lookSizes[productId] != null,
    );
  }

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<int>(0, (total, review) => total + review.rating);
    return sum / reviews.length;
  }

  FitFeedback? get dominantFit {
    if (reviews.isEmpty) return null;

    final counts = <FitFeedback, int>{
      for (final fit in FitFeedback.values) fit: 0,
    };
    for (final review in reviews) {
      counts[review.fit] = (counts[review.fit] ?? 0) + 1;
    }

    return counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  ProductDetailsReady copyWith({
    String? selectedColor,
    String? selectedSize,
    Set<String>? subscribedSizes,
    List<Product>? lookProducts,
    Set<String>? selectedLookIds,
    Map<String, String>? lookSizes,
    List<ProductReview>? reviews,
  }) {
    return ProductDetailsReady(
      product: product,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      subscribedSizes: subscribedSizes ?? this.subscribedSizes,
      lookProducts: lookProducts ?? this.lookProducts,
      selectedLookIds: selectedLookIds ?? this.selectedLookIds,
      lookSizes: lookSizes ?? this.lookSizes,
      reviews: reviews ?? this.reviews,
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
    this._getCompleteLook,
    this._getProductReviews,
    this._submitProductReview,
    this._addToCart,
    this._subscribeBackInStock,
  ) : super(const ProductDetailsLoading());

  final GetProductDetails _getProductDetails;
  final GetCompleteLook _getCompleteLook;
  final GetProductReviews _getProductReviews;
  final SubmitProductReview _submitProductReview;
  final AddToCart _addToCart;
  final SubscribeBackInStock _subscribeBackInStock;

  Future<void> load(String id) async {
    emit(const ProductDetailsLoading());

    try {
      final product = await _getProductDetails(id);
      final lookProducts = await _getCompleteLook(id);
      final reviews = await _getProductReviews(id);

      emit(
        ProductDetailsReady(
          product: product,
          selectedColor: product.colors.isEmpty ? null : product.colors.first,
          lookProducts: lookProducts,
          selectedLookIds:
              lookProducts.map((product) => product.id).toSet(),
          reviews: reviews,
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

  void toggleLookProduct(String productId) {
    final current = state;
    if (current is! ProductDetailsReady) return;

    final next = Set<String>.from(current.selectedLookIds);
    if (!next.add(productId)) next.remove(productId);
    emit(current.copyWith(selectedLookIds: next));
  }

  void selectLookSize(String productId, String size) {
    final current = state;
    if (current is! ProductDetailsReady) return;

    final product = current.lookProducts.firstWhere(
      (item) => item.id == productId,
    );
    if (!product.isSizeAvailable(size)) return;

    emit(
      current.copyWith(
        lookSizes: <String, String>{
          ...current.lookSizes,
          productId: size,
        },
      ),
    );
  }

  Future<int> addSelectedLookToCart() async {
    final current = state;
    if (current is! ProductDetailsReady || !current.canAddLook) return 0;

    var added = 0;
    for (final product in current.lookProducts) {
      if (!current.selectedLookIds.contains(product.id)) continue;

      final size = current.lookSizes[product.id];
      final color = product.colors.isEmpty ? null : product.colors.first;
      if (size == null || color == null) continue;

      await _addToCart(
        CartItem(product: product, color: color, size: size),
      );
      added++;
    }
    return added;
  }

  Future<bool> submitReview({
    required int rating,
    required FitFeedback fit,
    required String comment,
  }) async {
    final current = state;
    if (current is! ProductDetailsReady ||
        rating < 1 ||
        rating > 5 ||
        comment.trim().isEmpty) {
      return false;
    }

    final review = ProductReview(
      id: 'review-${DateTime.now().millisecondsSinceEpoch}',
      productId: current.product.id,
      authorName: 'You',
      rating: rating,
      comment: comment.trim(),
      fit: fit,
      createdAt: DateTime.now(),
    );

    await _submitProductReview(review);
    final reviews = await _getProductReviews(current.product.id);
    emit(current.copyWith(reviews: reviews));
    return true;
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
