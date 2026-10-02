import 'dart:async';

enum PushEnableResult { enabled, denied, notReady, unsupported }

class PushMessage {
  const PushMessage(
      {required this.ownerUid,
      required this.title,
      required this.body,
      this.productId,
      this.orderId,
      this.opened = false});
  final String ownerUid;
  final String title;
  final String body;
  final String? productId;
  final String? orderId;
  final bool opened;
}

abstract interface class PushNotifications {
  Stream<PushMessage> get messages;
  Future<void> start();
  PushMessage? takeInitialMessage();
  Future<PushEnableResult> enable();
  Future<void> disable();
  Future<void> beforeAccountChange();
  Future<void> afterAccountChange();
  Future<void> dispose();
}
