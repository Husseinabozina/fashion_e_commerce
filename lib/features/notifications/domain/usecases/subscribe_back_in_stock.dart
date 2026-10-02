import 'package:fashion_e_commerce/features/notifications/domain/entities/back_in_stock_subscription.dart';
import 'package:fashion_e_commerce/features/notifications/domain/repositories/notifications_repository.dart';

class SubscribeBackInStock {
  const SubscribeBackInStock(this._repository);

  final NotificationsRepository _repository;

  Future<bool> call(BackInStockSubscription subscription) {
    return _repository.subscribeBackInStock(subscription);
  }
}
