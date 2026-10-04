import 'package:fashion_e_commerce/features/notifications/domain/entities/app_notification.dart';
import 'package:fashion_e_commerce/features/notifications/domain/entities/back_in_stock_subscription.dart';

abstract interface class NotificationsRepository {
  Future<List<AppNotification>> getNotifications();

  Future<List<AppNotification>> markAllRead();

  Future<bool> subscribeBackInStock(
    BackInStockSubscription subscription,
  );

  Future<bool> isSubscribed(
    BackInStockSubscription subscription,
  );
}
