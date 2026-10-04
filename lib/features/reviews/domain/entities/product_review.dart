enum FitFeedback {
  runsSmall,
  trueToSize,
  runsLarge,
}

extension FitFeedbackLabel on FitFeedback {
  String get label => switch (this) {
        FitFeedback.runsSmall => 'Runs small',
        FitFeedback.trueToSize => 'True to size',
        FitFeedback.runsLarge => 'Runs large',
      };
}

class ProductReview {
  const ProductReview({
    required this.id,
    required this.productId,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.fit,
    required this.createdAt,
    this.verifiedPurchase = false,
  });

  final String id;
  final String productId;
  final String authorName;
  final int rating;
  final String comment;
  final FitFeedback fit;
  final DateTime createdAt;
  final bool verifiedPurchase;
}
