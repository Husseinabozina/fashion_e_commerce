class OrderReceipt {
  const OrderReceipt({
    required this.orderId,
    this.ownerId,
    required this.total,
    required this.deliveryEta,
  });

  final String orderId;
  final String? ownerId;
  final double total;
  final String deliveryEta;
}
