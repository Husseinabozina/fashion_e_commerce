import 'package:fashion_e_commerce/features/reviews/data/datasources/in_memory_reviews_data_source.dart';
import 'package:fashion_e_commerce/features/reviews/data/repositories/reviews_repository_impl.dart';
import 'package:fashion_e_commerce/features/reviews/domain/entities/product_review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reviews can be read and submitted for a product', () async {
    final repository = ReviewsRepositoryImpl(
      InMemoryReviewsDataSource(),
    );

    final before = await repository.getReviews('nb-9060');
    expect(before, isNotEmpty);

    final created = await repository.addReview(
      ProductReview(
        id: 'review-test',
        productId: 'nb-9060',
        authorName: 'Tester',
        rating: 5,
        comment: 'Fits exactly as expected.',
        fit: FitFeedback.trueToSize,
        createdAt: DateTime(2026, 10, 1),
      ),
    );

    expect(created.rating, 5);

    final after = await repository.getReviews('nb-9060');
    expect(after.length, before.length + 1);
    expect(after.first.id, 'review-test');
  });
}
