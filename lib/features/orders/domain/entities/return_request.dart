enum ReturnRequestType { returnItem, exchangeSize }

enum ReturnRequestStatus { submitted, approved, completed }

class ReturnRequest {
  const ReturnRequest({
    required this.id,
    required this.orderId,
    required this.itemKey,
    required this.type,
    required this.reason,
    required this.status,
    this.requestedSize,
  });

  final String id;
  final String orderId;
  final String itemKey;
  final ReturnRequestType type;
  final String reason;
  final String? requestedSize;
  final ReturnRequestStatus status;
}
