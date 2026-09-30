class Product {
  const Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.colors,
    this.previousPrice,
    this.isNew = false,
  });

  final String id;
  final String brand;
  final String name;
  final double price;
  final double? previousPrice;
  final String imageUrl;
  final List<String> colors;
  final bool isNew;
}
