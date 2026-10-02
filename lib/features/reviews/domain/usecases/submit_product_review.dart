import 'package:fashion_e_commerce/features/reviews/domain/entities/product_review.dart';
import 'package:fashion_e_commerce/features/reviews/domain/repositories/reviews_repository.dart';

class SubmitProductReview {
  const SubmitProductReview(this._repository);

  final ReviewsRepository _repository;

  Future<ProductReview> call(ProductReview review) {
    return _repository.addReview(review);
  }
}
