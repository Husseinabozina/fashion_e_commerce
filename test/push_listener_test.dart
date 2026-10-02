import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fashion_e_commerce/features/notifications/domain/services/push_notifications.dart';
import 'package:fashion_e_commerce/features/notifications/presentation/widgets/push_listener.dart';

class TestPush implements PushNotifications {
  final events = StreamController<PushMessage>.broadcast();
  PushMessage? initial;
  @override
  Stream<PushMessage> get messages => events.stream;
  @override
  PushMessage? takeInitialMessage() {
    final message = initial;
    initial = null;
    return message;
  }

  @override
  Future<void> start() async {}
  @override
  Future<PushEnableResult> enable() async => PushEnableResult.enabled;
  @override
  Future<void> disable() async {}
  @override
  Future<void> beforeAccountChange() async {}
  @override
  Future<void> afterAccountChange() async {}
  @override
  Future<void> dispose() async {
    await events.close();
  }
}

void main() {
  late TestPush push;
  late AuthCubit auth;
  setUp(() async {
    configureDependencies();
    push = TestPush();
    serviceLocator.registerSingleton<PushNotifications>(push);
    auth = serviceLocator<AuthCubit>();
    await auth.load();
  });
  tearDown(() async {
    await auth.close();
    await push.dispose();
    await serviceLocator.reset();
  });
  Widget app() => BlocProvider.value(
      value: auth,
      child: PushListener(
          builder: (navigator, messenger, observer) => MaterialApp(
                  navigatorKey: navigator,
                  scaffoldMessengerKey: messenger,
                  navigatorObservers: [
                    observer
                  ],
                  routes: {
                    Routes.initialSplash: (context) => Scaffold(
                        body: TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushReplacementNamed(Routes.home),
                            child: const Text('Enter'))),
                    Routes.home: (_) => const Scaffold(body: Text('Home')),
                    Routes.productDetails: (_) =>
                        const Scaffold(body: Text('Product')),
                    Routes.notifications: (_) =>
                        const Scaffold(body: Text('Inbox')),
                  })));
  testWidgets(
      'cold notification waits for home after splash before opening its product',
      (tester) async {
    push.initial = PushMessage(
        ownerUid: auth.sessionKey,
        title: 'NOVA',
        body: 'Ready',
        productId: 'p',
        opened: true);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Product'), findsNothing);
    await tester.tap(find.text('Enter'));
    await tester.pumpAndSettle();
    expect(find.text('Product'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('another account cannot display or open notification content',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('Enter'));
    await tester.pumpAndSettle();
    push.events.add(const PushMessage(
        ownerUid: 'another-user',
        title: 'NOVA',
        body: 'Private',
        productId: 'p',
        opened: true));
    await tester.pumpAndSettle();
    expect(find.text('Product'), findsNothing);
    push.events.add(const PushMessage(
        ownerUid: 'another-user', title: 'NOVA', body: 'Private'));
    await tester.pump();
    expect(find.text('Private'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
