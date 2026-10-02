import 'package:fashion_e_commerce/features/notifications/domain/entities/app_notification.dart';
import 'package:fashion_e_commerce/features/notifications/domain/entities/back_in_stock_subscription.dart';

abstract interface class NotificationsDataSource {
  Future<List<AppNotification>> readNotifications();

  Future<List<AppNotification>> markAllRead();

  Future<bool> subscribe(BackInStockSubscription subscription);

  Future<bool> containsSubscription(
    BackInStockSubscription subscription,
  );
}
