import 'package:fashion_e_commerce/features/reviews/domain/entities/product_review.dart';

abstract interface class ReviewsRepository {
  Future<List<ProductReview>> getReviews(String productId);

  Future<ProductReview> addReview(ProductReview review);
}
