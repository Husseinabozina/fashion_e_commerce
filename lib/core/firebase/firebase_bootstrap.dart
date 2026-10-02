import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:fashion_e_commerce/features/notifications/domain/services/push_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fashion_e_commerce/app/app.dart';
import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:fashion_e_commerce/firebase_options.dart';
import 'package:flutter/material.dart';

Future<void> initializeFirebaseDependencies() async {
  if (Firebase.apps.isEmpty)
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instanceFor(
      app: Firebase.app(), databaseId: 'nova-app');
  if (const bool.fromEnvironment('USE_FIREBASE_EMULATORS')) {
    const host = String.fromEnvironment('FIREBASE_EMULATOR_HOST',
        defaultValue: '127.0.0.1');
    await auth.useAuthEmulator(host, 9099);
    db.useFirestoreEmulator(host, 8080);
    db.settings = const Settings(persistenceEnabled: false);
  }
  await auth.authStateChanges().first;
  await FirebaseAuthDataSource.ensureSession(auth);
  final mobilePush = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  configureDependencies(
      firestore: db,
      firebaseAuth: auth,
      messaging: mobilePush ? FirebaseMessaging.instance : null);
  if (serviceLocator.isRegistered<PushNotifications>()) {
    // Push readiness does not block browsing/authentication.
    try {
      await serviceLocator<PushNotifications>().start();
    } catch (_) {}
  }
}

class FirebaseBootstrap extends StatefulWidget {
  const FirebaseBootstrap({super.key});
  @override
  State<FirebaseBootstrap> createState() => _FirebaseBootstrapState();
}

class _FirebaseBootstrapState extends State<FirebaseBootstrap> {
  late Future<void> _ready = initializeFirebaseDependencies();
  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) return const FashionApp();
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: Scaffold(
                body: SafeArea(
                    child: Center(
                        child: Padding(
              padding: const EdgeInsets.all(24),
              child: snapshot.hasError
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text(
                          'تعذر الاتصال. تأكد من الإنترنت وحاول مرة أخرى.\nCould not connect. Please check your connection.',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                          onPressed: () => setState(
                              () => _ready = initializeFirebaseDependencies()),
                          child: const Text('حاول مرة أخرى · Retry')),
                    ])
                  : const CircularProgressIndicator(color: AppColors.nearBlack),
            )))));
      });
}
