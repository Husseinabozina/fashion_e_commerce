import 'package:fashion_e_commerce/features/notifications/domain/entities/app_notification.dart';
import 'package:fashion_e_commerce/features/notifications/domain/usecases/get_notifications.dart';
import 'package:fashion_e_commerce/features/notifications/domain/usecases/mark_notifications_read.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class NotificationsState {
  const NotificationsState();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded(this.items);

  final List<AppNotification> items;

  int get unreadCount => items.where((item) => !item.isRead).length;
}

final class NotificationsFailure extends NotificationsState {
  const NotificationsFailure(this.message);

  final String message;
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(
    this._getNotifications,
    this._markNotificationsRead,
  ) : super(const NotificationsLoading());

  final GetNotifications _getNotifications;
  final MarkNotificationsRead _markNotificationsRead;

  Future<void> load() async {
    emit(const NotificationsLoading());
    try {
      emit(NotificationsLoaded(await _getNotifications()));
    } catch (_) {
      emit(const NotificationsFailure('Notifications could not be loaded.'));
    }
  }

  Future<void> markAllRead() async {
    emit(NotificationsLoaded(await _markNotificationsRead()));
  }
}
