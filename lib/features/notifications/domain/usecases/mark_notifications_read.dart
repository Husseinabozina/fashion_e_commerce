import 'package:fashion_e_commerce/features/notifications/domain/entities/app_notification.dart';
import 'package:fashion_e_commerce/features/notifications/domain/repositories/notifications_repository.dart';

class MarkNotificationsRead {
  const MarkNotificationsRead(this._repository);

  final NotificationsRepository _repository;

  Future<List<AppNotification>> call() {
    return _repository.markAllRead();
  }
}
