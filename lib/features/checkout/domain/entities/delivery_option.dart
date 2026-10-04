class DeliveryOption {
  const DeliveryOption({
    required this.id,
    required this.title,
    required this.eta,
    required this.price,
  });

  final String id;
  final String title;
  final String eta;
  final double price;
}
