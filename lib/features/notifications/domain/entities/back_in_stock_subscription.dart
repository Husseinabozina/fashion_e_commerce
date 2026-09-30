class BackInStockSubscription {
  const BackInStockSubscription({
    required this.productId,
    required this.color,
    required this.size,
  });

  final String productId;
  final String color;
  final String size;

  String get key => '$productId::$color::$size';
}
