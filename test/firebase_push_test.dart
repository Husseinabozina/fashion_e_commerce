import 'dart:async';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:fashion_e_commerce/features/notifications/data/datasources/firebase_push_notifications.dart';
import 'package:fashion_e_commerce/features/notifications/domain/services/push_notifications.dart';

class TestMessaging implements FirebaseMessaging {
  AuthorizationStatus status = AuthorizationStatus.authorized;
  Completer<String?>? tokenResult;
  int prompts = 0;
  bool deleted = false;
  final refresh = StreamController<String>.broadcast();
  NotificationSettings settings() => NotificationSettings(
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.disabled,
      authorizationStatus: status,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.disabled,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      timeSensitive: AppleNotificationSetting.disabled,
      sound: AppleNotificationSetting.enabled,
      criticalAlert: AppleNotificationSetting.disabled,
      providesAppNotificationSettings: AppleNotificationSetting.disabled);
  @override
  Future<NotificationSettings> requestPermission(
      {bool alert = true,
      bool announcement = false,
      bool badge = true,
      bool carPlay = false,
      bool criticalAlert = false,
      bool provisional = false,
      bool sound = true,
      bool providesAppNotificationSettings = false}) async {
    prompts++;
    return settings();
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async => settings();
  @override
  Future<String?> getToken(
          {String? vapidKey, String? serviceWorkerScriptPath}) async =>
      tokenResult == null
          ? 'device-token-12345678901234567890'
          : await tokenResult!.future;
  @override
  Future<void> setAutoInitEnabled(bool enabled) async {}
  @override
  Future<void> deleteToken() async {
    deleted = true;
  }

  @override
  Future<String?> getAPNSToken() async => null;
  @override
  Stream<String> get onTokenRefresh => refresh.stream;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestAuth extends MockFirebaseAuth {
  TestAuth() : super(signedIn: true, mockUser: MockUser(uid: 'alice'));
  @override
  Future<UserCredential> signInAnonymously() async {
    mockUser = MockUser(uid: 'new-guest', isAnonymous: true);
    return super.signInAnonymously();
  }
}

void main() {
  late FakeFirebaseFirestore db;
  late MockFirebaseAuth auth;
  late TestMessaging messaging;
  late FirebasePushNotifications push;
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    db = FakeFirebaseFirestore();
    auth = TestAuth();
    messaging = TestMessaging();
    push = FirebasePushNotifications(FirebaseAccountStore(db, auth), messaging);
  });
  tearDown(() async {
    await push.dispose();
    await messaging.refresh.close();
    debugDefaultTargetPlatformOverride = null;
  });
  test(
      'explicit enable registers privately, revokes before switching, and disables cleanly',
      () async {
    expect(await push.enable(), PushEnableResult.enabled);
    expect(messaging.prompts, 1);
    expect((await db.collection('users/alice/devices').get()).docs.length, 1);
    await push.beforeAccountChange();
    expect((await db.collection('users/alice/devices').get()).docs, isEmpty);
    auth.mockUser = MockUser(uid: 'bob');
    await push.afterAccountChange();
    expect((await db.collection('users/bob/devices').get()).docs, isEmpty);
    expect(messaging.prompts, 1);
    await push.enable();
    await push.disable();
    expect((await db.collection('users/bob/devices').get()).docs, isEmpty);
    expect(messaging.deleted, true);
    expect((await db.doc('users/bob/settings/push').get()).data()!['enabled'],
        false);
  });
  test('a new service on the same installation transfers the exclusive binding',
      () async {
    await push.enable();
    await push.dispose();
    auth.mockUser = MockUser(uid: 'bob');
    push = FirebasePushNotifications(FirebaseAccountStore(db, auth), messaging);
    await push.enable();
    final key =
        FirebaseAccountStore.documentKey('device-token-12345678901234567890');
    expect(
        (await db.doc('deviceBindings/$key').get()).data()!['ownerUid'], 'bob');
    expect((await db.collection('users/alice/devices').get()).docs.length, 1);
    expect((await db.collection('users/bob/devices').get()).docs.length, 1);
  });
  test('denied permission and missing APNs token never register', () async {
    messaging.status = AuthorizationStatus.denied;
    expect(await push.enable(), PushEnableResult.denied);
    messaging.status = AuthorizationStatus.authorized;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(await push.enable(), PushEnableResult.notReady);
    expect((await db.collection('users/alice/devices').get()).docs, isEmpty);
  });
  test('pending permission/token work cannot rebind the departed account',
      () async {
    messaging.tokenResult = Completer();
    final pending = push.enable();
    await Future<void>.delayed(Duration.zero);
    await push.beforeAccountChange();
    auth.mockUser = MockUser(uid: 'bob');
    messaging.tokenResult!.complete('device-token-12345678901234567890');
    expect(await pending, PushEnableResult.notReady);
    expect((await db.collection('users/alice/devices').get()).docs, isEmpty);
    expect((await db.collection('users/bob/devices').get()).docs, isEmpty);
  });
  test('saved opt-in restores without a new OS permission prompt', () async {
    await db.doc('users/alice/settings/push').set({'enabled': true});
    await push.afterAccountChange();
    expect(messaging.prompts, 0);
    expect((await db.collection('users/alice/devices').get()).docs.length, 1);
  });
  test('auth transition waits for device revocation before changing the user',
      () async {
    await push.enable();
    var revoked = false;
    final source = FirebaseAuthDataSource(auth, beforeAccountChange: () async {
      expect(auth.currentUser!.uid, 'alice');
      await push.beforeAccountChange();
      revoked = (await db.collection('users/alice/devices').get()).docs.isEmpty;
    }, afterAccountChange: push.afterAccountChange);
    await source.signOut();
    expect(revoked, true);
    expect(auth.currentUser!.isAnonymous, true);
  });
}
