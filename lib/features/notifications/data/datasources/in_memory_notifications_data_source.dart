import 'package:fashion_e_commerce/features/notifications/data/datasources/notifications_data_source.dart';
import 'package:fashion_e_commerce/features/notifications/domain/entities/app_notification.dart';
import 'package:fashion_e_commerce/features/notifications/domain/entities/back_in_stock_subscription.dart';

class InMemoryNotificationsDataSource implements NotificationsDataSource {
  final List<AppNotification> _notifications = <AppNotification>[
    AppNotification(
      id: 'notif-1',
      title: 'Your order is moving',
      message: 'NOVA-025884 has left the warehouse.',
      createdAt: DateTime(2026, 9, 25, 11, 30),
      type: AppNotificationType.order,
    ),
    AppNotification(
      id: 'notif-2',
      title: 'Size 44 is back',
      message: 'NEW BALANCE 9060 is available again in Black.',
      createdAt: DateTime(2026, 9, 29, 17, 10),
      type: AppNotificationType.backInStock,
      productId: 'nb-9060',
    ),
  ];

  final Set<String> _subscriptions = <String>{};

  @override
  Future<List<AppNotification>> readNotifications() async {
    final sorted = List<AppNotification>.from(_notifications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<AppNotification>.unmodifiable(sorted);
  }

  @override
  Future<List<AppNotification>> markAllRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    return readNotifications();
  }

  @override
  Future<bool> subscribe(BackInStockSubscription subscription) async {
    return _subscriptions.add(subscription.key);
  }

  @override
  Future<bool> containsSubscription(
    BackInStockSubscription subscription,
  ) async {
    return _subscriptions.contains(subscription.key);
  }
}
