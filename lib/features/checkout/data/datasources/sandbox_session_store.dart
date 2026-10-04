import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import '../../domain/entities/sandbox_payment.dart';

abstract interface class SandboxSessionStore {
  Future<SandboxPaymentSession?> read(String key, String? owner);
  Future<void> save(SandboxPaymentSession session);
  Future<void> remove(SandboxPaymentSession session);
}

class MemorySandboxSessionStore implements SandboxSessionStore {
  final _sessions = <String, SandboxPaymentSession>{};
  String _key(String key, String? owner) => '${owner ?? 'demo'}:$key';
  @override
  Future<SandboxPaymentSession?> read(String key, String? owner) async =>
      _sessions[_key(key, owner)];
  @override
  Future<void> save(SandboxPaymentSession session) async {
    _sessions[_key(session.attemptKey, session.ownerId)] = session;
  }

  @override
  Future<void> remove(SandboxPaymentSession session) async {
    _sessions.remove(_key(session.attemptKey, session.ownerId));
  }
}

class FirestoreSandboxSessionStore implements SandboxSessionStore {
  FirestoreSandboxSessionStore(this.store);
  final FirebaseAccountStore store;

  DocumentReference<Map<String, dynamic>> _ref(String key, String? owner) {
    if (owner == null || store.uid != owner) {
      throw StateError('Account changed during sandbox checkout.');
    }
    return store.db
        .collection('users')
        .doc(owner)
        .collection('sandboxPayments')
        .doc(key);
  }

  @override
  Future<SandboxPaymentSession?> read(String key, String? owner) async {
    final doc = await _ref(key, owner).get();
    if (store.uid != owner) throw StateError('Account changed.');
    if (!doc.exists) return null;
    final d = doc.data()!;
    // A completed demo order consumes its invoice, even if pointer cleanup
    // failed. Buying the same basket later must start a fresh test payment.
    final completed = await store.db
        .collection('users')
        .doc(owner)
        .collection('demoOrders')
        .doc('NOVA-TEST-${d['invoiceId']}')
        .get();
    if (store.uid != owner) throw StateError('Account changed.');
    if (completed.exists) {
      await _ref(key, owner).delete();
      return null;
    }
    return SandboxPaymentSession(
      attemptKey: key,
      ownerId: owner,
      reference: d['reference'] as String,
      invoiceId: d['invoiceId'] as int,
      checkoutUrl: Uri.parse(d['checkoutUrl'] as String),
      orderTotalEgp: (d['orderTotalEgp'] as num).toDouble(),
    );
  }

  @override
  Future<void> save(SandboxPaymentSession session) async {
    final ref = _ref(session.attemptKey, session.ownerId);
    await store.db.runTransaction((tx) async {
      final existing = await tx.get(ref);
      if (existing.exists) {
        if (existing.data()!['invoiceId'] != session.invoiceId) {
          throw StateError('A sandbox invoice already exists.');
        }
        return;
      }
      tx.set(ref, {
        'isDemo': true,
        'reference': session.reference,
        'invoiceId': session.invoiceId,
        'checkoutUrl': session.checkoutUrl.toString(),
        'orderTotalEgp': session.orderTotalEgp,
        'amount': SandboxPaymentSession.testAmount,
        'currency': SandboxPaymentSession.testCurrency,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
    if (store.uid != session.ownerId) throw StateError('Account changed.');
  }

  @override
  Future<void> remove(SandboxPaymentSession session) async {
    await _ref(session.attemptKey, session.ownerId).delete();
  }
}
