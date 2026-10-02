import 'package:fashion_e_commerce/features/reviews/domain/entities/product_review.dart';

abstract interface class ReviewsDataSource {
  Future<List<ProductReview>> read(String productId);

  Future<ProductReview> add(ProductReview review);
}
