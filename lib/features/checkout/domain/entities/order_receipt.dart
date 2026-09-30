class OrderReceipt {
  const OrderReceipt({
    required this.orderId,
    required this.total,
    required this.deliveryEta,
  });

  final String orderId;
  final double total;
  final String deliveryEta;
}
