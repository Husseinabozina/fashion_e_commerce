enum OrderStatus {
  placed,
  confirmed,
  preparing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  returnRequested,
  returned,
  refunded,
}

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
        OrderStatus.placed => 'Order placed',
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.preparing => 'Preparing',
        OrderStatus.shipped => 'Shipped',
        OrderStatus.outForDelivery => 'Out for delivery',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
        OrderStatus.returnRequested => 'Return requested',
        OrderStatus.returned => 'Returned',
        OrderStatus.refunded => 'Refunded',
      };
}
