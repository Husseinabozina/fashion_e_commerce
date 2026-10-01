import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/notifications/domain/entities/app_notification.dart';
import 'package:fashion_e_commerce/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context).notifications.toUpperCase()),
        actions: [
          TextButton(
            onPressed: context.read<NotificationsCubit>().markAllRead,
            child: Text(
              AppStrings.of(context).isArabic ? 'قراءة الكل' : 'MARK ALL READ',
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          return switch (state) {
            NotificationsLoading() => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.nearBlack,
                ),
              ),
            NotificationsFailure(:final message) =>
              Center(child: Text(AppStrings.of(context).loadFailure(message))),
            NotificationsLoaded(:final items) when items.isEmpty =>
              const _EmptyNotifications(),
            NotificationsLoaded(:final items) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _NotificationCard(item: items[index]);
                },
              ),
          };
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final AppNotification item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.productId == null
          ? null
          : () => Navigator.of(context).pushNamed(
                Routes.productDetails,
                arguments: item.productId,
              ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: item.isRead
              ? AppColors.white
              : AppColors.acidLime.withValues(alpha: 0.28),
          border: Border.all(color: AppColors.concrete),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationIcon(type: item.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.of(context).notificationText(item.title),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.of(context).notificationText(item.message),
                    style: const TextStyle(
                      color: AppColors.midGray,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.nearBlack,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type});

  final AppNotificationType type;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      AppNotificationType.order => AppIcons.delivery,
      AppNotificationType.backInStock => AppIcons.inventory,
      AppNotificationType.priceDrop => AppIcons.priceDrop,
      AppNotificationType.promotion => AppIcons.tag,
    };

    return Icon(icon, size: 23);
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppStrings.of(context).isArabic
            ? 'لا توجد إشعارات.'
            : 'NO NOTIFICATIONS.',
        style: AppTheme.displayFor(context, fontSize: 28),
      ),
    );
  }
}
