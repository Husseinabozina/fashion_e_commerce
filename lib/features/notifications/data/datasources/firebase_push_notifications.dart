import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import '../../domain/services/push_notifications.dart';

/// Permission is requested only from the explicit enable action. Server sends
/// generic text; account-specific routes are opened only for the matching UID.
class FirebasePushNotifications implements PushNotifications {
  FirebasePushNotifications(this.store, this.messaging);
  final FirebaseAccountStore store;
  final FirebaseMessaging messaging;
  final _messages = StreamController<PushMessage>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  PushMessage? _initial;
  @override
  PushMessage? takeInitialMessage() {
    final value = _initial;
    _initial = null;
    return value;
  }

  String? _boundUid;
  String? _token;
  Future<void> _writes = Future.value();
  int _generation = 0;
  bool _disposed = false;
  bool _started = false;
  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  bool get _emulated => const bool.fromEnvironment('USE_FIREBASE_EMULATORS');
  @override
  Stream<PushMessage> get messages => _messages.stream;

  @override
  Future<void> start() async {
    if (!_supported || _emulated || _started) return;
    _started = true;
    _subscriptions.add(FirebaseMessaging.onMessage
        .listen((message) => _receive(message, false)));
    _subscriptions.add(FirebaseMessaging.onMessageOpenedApp
        .listen((message) => _receive(message, true)));
    _subscriptions.add(messaging.onTokenRefresh.listen((token) {
      final uid = _boundUid;
      if (uid != null) {
        _writes = _writes
            .then((_) =>
                _boundUid == uid ? _register(token, uid) : Future<void>.value())
            .catchError((Object _) {});
      }
    }));
    final initial = await messaging.getInitialMessage();
    if (initial != null) _receive(initial, true, initial: true);
    await afterAccountChange();
  }

  void _receive(RemoteMessage message, bool opened, {bool initial = false}) {
    final uid = store.auth.currentUser?.uid;
    if (_disposed || uid == null || message.data['ownerUid'] != uid) return;
    final event = PushMessage(
        ownerUid: uid,
        title: message.notification?.title ?? 'NOVA',
        body:
            message.notification?.body ?? 'There is an update in your account.',
        productId: message.data['productId'],
        orderId: message.data['orderId'],
        opened: opened);
    if (initial) {
      _initial = event;
    } else {
      _messages.add(event);
    }
  }

  Future<PushEnableResult> _bind({required bool requestPermission}) async {
    if (!_supported || _emulated) return PushEnableResult.unsupported;
    final uid = store.uid;
    final generation = _generation;
    final settings = requestPermission
        ? await messaging.requestPermission(
            alert: true, badge: true, sound: true)
        : await messaging.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      return PushEnableResult.denied;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        await messaging.getAPNSToken() == null) {
      return PushEnableResult.notReady;
    }
    await messaging.setAutoInitEnabled(true);
    final token = await messaging.getToken();
    if (token == null ||
        store.auth.currentUser?.uid != uid ||
        _disposed ||
        generation != _generation) {
      return PushEnableResult.notReady;
    }
    _boundUid = uid;
    _writes = _writes.then(
        (_) => _boundUid == uid ? _register(token, uid) : Future<void>.value());
    try {
      await _writes;
    } catch (_) {
      _writes = Future.value();
      rethrow;
    }
    if (_disposed ||
        generation != _generation ||
        store.auth.currentUser?.uid != uid) {
      return PushEnableResult.notReady;
    }
    return PushEnableResult.enabled;
  }

  Future<void> _register(String token, String uid) async {
    if (_disposed || store.auth.currentUser?.uid != uid) return;
    final devices = store.db.collection('users').doc(uid).collection('devices');
    final previous = _token;
    final batch = store.db.batch();
    batch.set(devices.doc(FirebaseAccountStore.documentKey(token)), {
      'token': token,
      'platform': defaultTargetPlatform.name,
      'updatedAt': FieldValue.serverTimestamp()
    });
    batch.set(
        store.db
            .collection('deviceBindings')
            .doc(FirebaseAccountStore.documentKey(token)),
        {'ownerUid': uid, 'updatedAt': FieldValue.serverTimestamp()});
    if (previous != null && previous != token) {
      batch.delete(devices.doc(FirebaseAccountStore.documentKey(previous)));
      batch.delete(store.db
          .collection('deviceBindings')
          .doc(FirebaseAccountStore.documentKey(previous)));
    }
    await batch.commit();
    if (store.auth.currentUser?.uid == uid) _token = token;
  }

  @override
  Future<PushEnableResult> enable() async {
    final selected = store.collection('settings').doc('push');
    final result = await _bind(requestPermission: true);
    if (result == PushEnableResult.enabled) {
      await selected.set({'enabled': true});
    }
    return result;
  }

  @override
  Future<void> beforeAccountChange() async {
    _generation++;
    final uid = _boundUid;
    _boundUid = null;
    await _writes;
    final token = _token;
    if (uid != null && token != null) {
      final key = FirebaseAccountStore.documentKey(token);
      final batch = store.db.batch();
      batch.delete(
          store.db.collection('users').doc(uid).collection('devices').doc(key));
      batch.delete(store.db.collection('deviceBindings').doc(key));
      await batch.commit();
    }
    _token = null;
  }

  @override
  Future<void> afterAccountChange() async {
    if (!_supported || _emulated || _disposed) return;
    final uid = store.uid;
    final generation = _generation;
    final enabled = (await store.collection('settings').doc('push').get())
            .data()?['enabled'] ==
        true;
    if (enabled &&
        store.auth.currentUser?.uid == uid &&
        generation == _generation) {
      await _bind(requestPermission: false);
    }
  }

  @override
  Future<void> disable() async {
    final uid = store.uid;
    final settings = store.collection('settings').doc('push');
    await beforeAccountChange();
    if (store.auth.currentUser?.uid != uid || _disposed) return;
    await settings.set({'enabled': false});
    if (_supported && !_emulated) {
      await messaging.deleteToken();
      await messaging.setAutoInitEnabled(false);
    }
  }

  @override
  Future<void> dispose() async {
    _generation++;
    _disposed = true;
    _boundUid = null;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _messages.close();
  }
}
