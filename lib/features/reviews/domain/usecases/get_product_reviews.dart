import 'package:fashion_e_commerce/features/reviews/domain/entities/product_review.dart';
import 'package:fashion_e_commerce/features/reviews/domain/repositories/reviews_repository.dart';

class GetProductReviews {
  const GetProductReviews(this._repository);

  final ReviewsRepository _repository;

  Future<List<ProductReview>> call(String productId) {
    return _repository.getReviews(productId);
  }
}
