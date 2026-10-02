import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order_status.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/return_request.dart';
import '../models/order_mapper.dart';
import 'orders_data_source.dart';

class FirestoreOrdersDataSource implements OrdersDataSource {
  FirestoreOrdersDataSource(this.store);
  final FirebaseAccountStore store;
  @override
  Future<void> save(Order order) async {
    if (order.ownerId != null && order.ownerId != store.uid)
      throw StateError('Account changed during checkout.');
    final ref = store.collection('demoOrders').doc(order.id);
    await store.db.runTransaction((tx) async {
      final existing = await tx.get(ref);
      // A retried placement uses the same id and cannot overwrite its receipt.
      if (!existing.exists) tx.set(ref, OrderMapper.encode(order));
    });
  }

  @override
  Future<List<Order>> readAll() async {
    final docs = await store.collection('demoOrders').get();
    return docs.docs
        .map((doc) => OrderMapper.decode(doc.id, doc.data()))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Order> readById(String orderId) async {
    final doc = await store.collection('demoOrders').doc(orderId).get();
    if (!doc.exists) throw StateError('Order not found.');
    return OrderMapper.decode(doc.id, doc.data()!);
  }

  @override
  Future<ReturnRequest> submitReturn(ReturnRequest request) async {
    final orders = store.collection('demoOrders');
    final returns = orders.parent!.collection('returnRequests');
    final orderRef = orders.doc(request.orderId);
    final requestRef = returns.doc(FirebaseAccountStore.documentKey(
        '${request.orderId}::${request.itemKey}'));
    await store.db.runTransaction((tx) async {
      final doc = await tx.get(orderRef);
      final order = OrderMapper.decode(doc.id, doc.data()!);
      if (order.status != OrderStatus.delivered ||
          !order.items.any((item) => item.key == request.itemKey)) {
        throw StateError('This item is not eligible for a return.');
      }
      tx.set(requestRef, {
        'orderId': request.orderId,
        'itemKey': request.itemKey,
        'itemIndex':
            order.items.indexWhere((item) => item.key == request.itemKey),
        'type': request.type.name,
        'reason': request.reason,
        'requestedSize': request.requestedSize,
        'status': 'submitted',
        'createdAt': FieldValue.serverTimestamp()
      });
      tx.update(orderRef,
          {'status': 'returnRequested', 'returnRequestId': requestRef.id});
    });
    return request;
  }
}
