import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/notifications/domain/entities/app_notification.dart';
import 'package:fashion_e_commerce/features/notifications/domain/entities/back_in_stock_subscription.dart';
import 'notifications_data_source.dart';

class FirestoreNotificationsDataSource implements NotificationsDataSource {
  FirestoreNotificationsDataSource(this.store);
  final FirebaseAccountStore store;
  @override
  Future<List<AppNotification>> readNotifications() async {
    final docs = await store.collection('notifications').get();
    final items = docs.docs.map((doc) {
      final d = doc.data();
      return AppNotification(
          id: doc.id,
          title: d['title'] as String,
          message: d['message'] as String,
          createdAt: (d['createdAt'] as Timestamp).toDate(),
          type: AppNotificationType.values.byName(d['type'] as String),
          productId: d['productId'] as String?,
          isRead: d['isRead'] as bool);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<List<AppNotification>> markAllRead() async {
    final docs = await store.collection('notifications').get();
    final batch = store.db.batch();
    for (final doc in docs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
    return readNotifications();
  }

  @override
  Future<bool> containsSubscription(
          BackInStockSubscription subscription) async =>
      (await store
              .collection('subscriptions')
              .doc(FirebaseAccountStore.documentKey(subscription.key))
              .get())
          .exists;
  @override
  Future<bool> subscribe(BackInStockSubscription subscription) async {
    final ref = store
        .collection('subscriptions')
        .doc(FirebaseAccountStore.documentKey(subscription.key));
    return store.db.runTransaction((tx) async {
      if ((await tx.get(ref)).exists) return false;
      tx.set(ref, {
        'productId': subscription.productId,
        'color': subscription.color,
        'size': subscription.size
      });
      return true;
    });
  }
}
