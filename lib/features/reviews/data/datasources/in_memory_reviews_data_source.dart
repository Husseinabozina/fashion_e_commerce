import 'package:fashion_e_commerce/features/reviews/data/datasources/reviews_data_source.dart';
import 'package:fashion_e_commerce/features/reviews/domain/entities/product_review.dart';

class InMemoryReviewsDataSource implements ReviewsDataSource {
  final List<ProductReview> _reviews = <ProductReview>[
    ProductReview(
      id: 'review-1',
      productId: 'nb-9060',
      authorName: 'Omar',
      rating: 5,
      comment: 'Very comfortable and the shape looks even better in person.',
      fit: FitFeedback.trueToSize,
      createdAt: DateTime(2026, 9, 24),
      verifiedPurchase: true,
    ),
    ProductReview(
      id: 'review-2',
      productId: 'nb-9060',
      authorName: 'Youssef',
      rating: 4,
      comment: 'Great everyday pair. I would stay with my normal size.',
      fit: FitFeedback.trueToSize,
      createdAt: DateTime(2026, 9, 18),
      verifiedPurchase: true,
    ),
    ProductReview(
      id: 'review-3',
      productId: 'nike-air',
      authorName: 'Karim',
      rating: 4,
      comment: 'Clean sneaker and easy to style.',
      fit: FitFeedback.runsSmall,
      createdAt: DateTime(2026, 9, 20),
      verifiedPurchase: true,
    ),
  ];

  @override
  Future<List<ProductReview>> read(String productId) async {
    final result = _reviews
        .where((review) => review.productId == productId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<ProductReview>.unmodifiable(result);
  }

  @override
  Future<ProductReview> add(ProductReview review) async {
    _reviews.insert(0, review);
    return review;
  }
}
