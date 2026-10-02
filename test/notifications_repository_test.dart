import 'package:fashion_e_commerce/features/notifications/data/datasources/in_memory_notifications_data_source.dart';
import 'package:fashion_e_commerce/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:fashion_e_commerce/features/notifications/domain/entities/back_in_stock_subscription.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notifications mark all read and keep stock subscriptions', () async {
    final repository = NotificationsRepositoryImpl(
      InMemoryNotificationsDataSource(),
    );

    final initial = await repository.getNotifications();
    expect(initial, isNotEmpty);
    expect(initial.any((item) => !item.isRead), isTrue);

    final read = await repository.markAllRead();
    expect(read.every((item) => item.isRead), isTrue);

    const subscription = BackInStockSubscription(
      productId: 'nb-9060',
      color: 'Black',
      size: '44',
    );

    expect(await repository.isSubscribed(subscription), isFalse);
    expect(await repository.subscribeBackInStock(subscription), isTrue);
    expect(await repository.isSubscribed(subscription), isTrue);
  });
}
