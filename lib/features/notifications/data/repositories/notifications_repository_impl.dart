import 'package:fashion_e_commerce/features/notifications/data/datasources/notifications_data_source.dart';
import 'package:fashion_e_commerce/features/notifications/domain/entities/app_notification.dart';
import 'package:fashion_e_commerce/features/notifications/domain/entities/back_in_stock_subscription.dart';
import 'package:fashion_e_commerce/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._dataSource);

  final NotificationsDataSource _dataSource;

  @override
  Future<List<AppNotification>> getNotifications() {
    return _dataSource.readNotifications();
  }

  @override
  Future<List<AppNotification>> markAllRead() {
    return _dataSource.markAllRead();
  }

  @override
  Future<bool> subscribeBackInStock(
    BackInStockSubscription subscription,
  ) {
    return _dataSource.subscribe(subscription);
  }

  @override
  Future<bool> isSubscribed(
    BackInStockSubscription subscription,
  ) {
    return _dataSource.containsSubscription(subscription);
  }
}
