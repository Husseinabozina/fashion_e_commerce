import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order_status.dart';
import 'package:fashion_e_commerce/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.of(context).orders.toUpperCase())),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          return switch (state) {
            OrdersLoading() => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.nearBlack,
                ),
              ),
            OrdersFailure(:final message) =>
              Center(child: Text(AppStrings.of(context).loadFailure(message))),
            OrdersLoaded(:final orders) when orders.isEmpty =>
              const _EmptyOrders(),
            OrdersLoaded(:final orders) => RefreshIndicator(
                onRefresh: context.read<OrdersCubit>().load,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _OrderCard(order: orders[index]);
                  },
                ),
              ),
          };
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        Routes.orderDetails,
        arguments: order.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  '#${order.id}',
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                _StatusPill(status: order.status),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 78,
                  height: 84,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.concrete.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Image.network(
                    order.items.first.product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(AppIcons.product),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.of(context).isArabic
                            ? '${order.items.length} منتج'
                            : '${order.items.length} ITEM${order.items.length == 1 ? '' : 'S'}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        order.items.first.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${order.total.toStringAsFixed(0)} EGP',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                Icon(AppIcons.arrowRight),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final completed = status == OrderStatus.delivered ||
        status == OrderStatus.returned ||
        status == OrderStatus.refunded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      color: completed ? AppColors.acidLime : AppColors.concrete,
      child: Text(
        AppStrings.of(context).orderStatus(status.label).toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          AppStrings.of(context).isArabic
              ? 'لا توجد\nطلبات بعد.'
              : 'NO ORDERS\nYET.',
          textAlign: TextAlign.center,
          style: AppTheme.displayFor(context, fontSize: 38),
        ),
      ),
    );
  }
}
