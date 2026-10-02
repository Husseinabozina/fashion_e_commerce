import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fashion_e_commerce/features/notifications/domain/services/push_notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Owns navigator/messenger keys for one account's MaterialApp and subscribes
/// only while that account subtree is mounted.
class PushListener extends StatefulWidget {
  const PushListener({super.key, required this.builder});
  final Widget Function(GlobalKey<NavigatorState>,
      GlobalKey<ScaffoldMessengerState>, NavigatorObserver) builder;
  @override
  State<PushListener> createState() => _PushListenerState();
}

class _PushListenerState extends State<PushListener> {
  final _navigator = GlobalKey<NavigatorState>();
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<PushMessage>? _subscription;
  StreamSubscription<AuthState>? _authSubscription;
  bool _appReady = false;
  PushMessage? _pending;
  late final _observer = _HomeObserver(() {
    _appReady = true;
    _consumeInitial();
  });
  void _consumeInitial() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_appReady ||
          context.read<AuthCubit>().state is! AuthReady ||
          !serviceLocator.isRegistered<PushNotifications>()) return;
      final message =
          _pending ?? serviceLocator<PushNotifications>().takeInitialMessage();
      _pending = null;
      if (message != null) _receive(message);
    });
  }

  @override
  void initState() {
    super.initState();
    if (serviceLocator.isRegistered<PushNotifications>()) {
      _subscription =
          serviceLocator<PushNotifications>().messages.listen(_receive);
      _authSubscription = context.read<AuthCubit>().stream.listen((state) {
        if (state is AuthReady && _appReady) _consumeInitial();
      });
    }
  }

  void _receive(PushMessage message) {
    if (!mounted || context.read<AuthCubit>().sessionKey != message.ownerUid) {
      return;
    }
    if (message.opened) {
      _open(message);
    } else {
      _messenger.currentState?.showSnackBar(SnackBar(
          content: Text(message.body),
          action:
              SnackBarAction(label: 'NOVA', onPressed: () => _open(message))));
    }
  }

  void _open(PushMessage message) {
    if (!mounted || context.read<AuthCubit>().sessionKey != message.ownerUid) {
      return;
    }
    if (!_appReady) {
      _pending = message;
      return;
    }
    final navigator = _navigator.currentState;
    if (message.productId != null) {
      navigator?.pushNamed(Routes.productDetails, arguments: message.productId);
    } else if (message.orderId != null) {
      navigator?.pushNamed(Routes.notifications);
    } else {
      navigator?.pushNamed(Routes.notifications);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(_navigator, _messenger, _observer);
}

class _HomeObserver extends NavigatorObserver {
  _HomeObserver(this.onReady);
  final VoidCallback onReady;
  void _check(Route<dynamic>? route) {
    if (route?.settings.name == Routes.home) onReady();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _check(route);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _check(newRoute);
}
