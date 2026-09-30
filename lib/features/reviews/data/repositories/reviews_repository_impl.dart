import 'package:fashion_e_commerce/features/reviews/data/datasources/reviews_data_source.dart';
import 'package:fashion_e_commerce/features/reviews/domain/entities/product_review.dart';
import 'package:fashion_e_commerce/features/reviews/domain/repositories/reviews_repository.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  const ReviewsRepositoryImpl(this._dataSource);

  final ReviewsDataSource _dataSource;

  @override
  Future<List<ProductReview>> getReviews(String productId) {
    return _dataSource.read(productId);
  }

  @override
  Future<ProductReview> addReview(ProductReview review) {
    return _dataSource.add(review);
  }
}
