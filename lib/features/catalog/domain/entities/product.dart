class Product {
  const Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.colors,
    required this.sizes,
    required this.fit,
    required this.description,
    this.previousPrice,
    this.isNew = false,
    this.outOfStockSizes = const <String>[],
  });

  final String id;
  final String brand;
  final String name;
  final String category;
  final double price;
  final double? previousPrice;
  final String imageUrl;
  final List<String> colors;
  final List<String> sizes;
  final String fit;
  final String description;
  final bool isNew;
  final List<String> outOfStockSizes;

  bool isSizeAvailable(String size) => !outOfStockSizes.contains(size);
}
