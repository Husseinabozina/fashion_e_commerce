import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order_status.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/return_request.dart';
import 'package:fashion_e_commerce/features/orders/presentation/cubit/order_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.of(context).orderDetails.toUpperCase())),
      body: BlocConsumer<OrderDetailsCubit, OrderDetailsState>(
        listener: (context, state) {
          if (state is OrderDetailsReady &&
              state.submittedRequest != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppStrings.of(context).isArabic
                      ? 'تم إرسال طلب الإرجاع.'
                      : 'Return request submitted.',
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            OrderDetailsLoading() => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.nearBlack,
                ),
              ),
            OrderDetailsFailure(:final message) =>
              Center(child: Text(message)),
            OrderDetailsReady(:final order) =>
              _OrderDetailsContent(order: order),
          };
        },
      ),
    );
  }
}

class _OrderDetailsContent extends StatelessWidget {
  const _OrderDetailsContent({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Text(
          '#${order.id}',
          style: AppTheme.displayFor(context, fontSize: 30),
        ),
        const SizedBox(height: 6),
        Text(
          order.status.label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.midGray,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppStrings.of(context).tracking,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        _TrackingTimeline(status: order.status),
        const SizedBox(height: 26),
        Text(
          AppStrings.of(context).items,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        ...order.items.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            color: AppColors.white,
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 76,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.concrete.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Image.network(
                    item.product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(AppIcons.product),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.brand,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        item.product.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.color} · SIZE ${item.size}',
                        style: const TextStyle(
                          color: AppColors.midGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (order.status == OrderStatus.delivered)
                  TextButton(
                    onPressed: () => _showReturnSheet(
                      context,
                      order,
                      item.key,
                      item.product.sizes,
                    ),
                    child: Text(AppStrings.of(context).returnLabel),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        _InfoCard(
          title: AppStrings.of(context).delivery.toUpperCase(),
          value: '${order.deliveryTitle}\n${order.deliveryEta}',
        ),
        _InfoCard(
          title: AppStrings.of(context).isArabic ? 'التوصيل إلى' : 'SHIP TO',
          value: order.shippingAddressLabel,
        ),
        _InfoCard(
          title: AppStrings.of(context).payment.toUpperCase(),
          value: order.paymentTitle,
        ),
        const Divider(height: 34),
        Row(
          children: [
            Text(
              AppStrings.of(context).total.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Text(
              '${order.total.toStringAsFixed(0)} EGP',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showReturnSheet(
    BuildContext context,
    Order order,
    String itemKey,
    List<String> sizes,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: context.read<OrderDetailsCubit>(),
        child: _ReturnExchangeSheet(
          order: order,
          itemKey: itemKey,
          sizes: sizes,
        ),
      ),
    );
  }
}

class _TrackingTimeline extends StatelessWidget {
  const _TrackingTimeline({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    const stages = <OrderStatus>[
      OrderStatus.placed,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.shipped,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];
    final current = stages.indexOf(status);
    final completedIndex = current == -1 ? 0 : current;

    return Column(
      children: List.generate(stages.length, (index) {
        final active = index <= completedIndex;
        final stage = stages[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.acidLime
                        : AppColors.offWhite,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.nearBlack,
                      width: 2,
                    ),
                  ),
                ),
                if (index != stages.length - 1)
                  Container(
                    width: 2,
                    height: 32,
                    color: active
                        ? AppColors.nearBlack
                        : AppColors.concrete,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                stage.label,
                style: TextStyle(
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  color: active
                      ? AppColors.nearBlack
                      : AppColors.midGray,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}

class _ReturnExchangeSheet extends StatefulWidget {
  const _ReturnExchangeSheet({
    required this.order,
    required this.itemKey,
    required this.sizes,
  });

  final Order order;
  final String itemKey;
  final List<String> sizes;

  @override
  State<_ReturnExchangeSheet> createState() =>
      _ReturnExchangeSheetState();
}

class _ReturnExchangeSheetState extends State<_ReturnExchangeSheet> {
  ReturnRequestType _type = ReturnRequestType.returnItem;
  String _reason = 'Wrong size';
  String? _size;

  @override
  Widget build(BuildContext context) {
    final reasons = <String>[
      'Wrong size',
      'Too small',
      'Too large',
      'Changed mind',
      'Different from images',
      'Damaged',
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.of(context).returnExchange,
                style: AppTheme.displayFor(context, fontSize: 34),
              ),
              const SizedBox(height: 18),
              SegmentedButton<ReturnRequestType>(
                segments: [
                  ButtonSegment(
                    value: ReturnRequestType.returnItem,
                    label: Text(AppStrings.of(context).returnLabel),
                  ),
                  ButtonSegment(
                    value: ReturnRequestType.exchangeSize,
                    label: Text(AppStrings.of(context).exchangeSize),
                  ),
                ],
                selected: <ReturnRequestType>{_type},
                onSelectionChanged: (value) {
                  setState(() => _type = value.first);
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _reason,
                decoration: InputDecoration(labelText: AppStrings.of(context).reason),
                items: reasons
                    .map(
                      (reason) => DropdownMenuItem(
                        value: reason,
                        child: Text(reason),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _reason = value);
                  }
                },
              ),
              if (_type == ReturnRequestType.exchangeSize) ...[
                const SizedBox(height: 14),
                Text(
                  AppStrings.of(context).newSize,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: widget.sizes
                      .map(
                        (size) => ChoiceChip(
                          label: Text(size),
                          selected: _size == size,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _size = size),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed:
                      _type == ReturnRequestType.exchangeSize && _size == null
                          ? null
                          : () async {
                              await context
                                  .read<OrderDetailsCubit>()
                                  .submitReturn(
                                    itemKey: widget.itemKey,
                                    type: _type,
                                    reason: _reason,
                                    requestedSize: _size,
                                  );
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                  child: Text(
                    AppStrings.of(context).submitRequest,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
