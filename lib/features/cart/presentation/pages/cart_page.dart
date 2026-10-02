import 'package:fashion_e_commerce/core/presentation/retry_panel.dart';
import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:fashion_e_commerce/features/promotions/presentation/cubit/promotions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            final quantity = state is CartLoaded ? state.totalQuantity : 0;
            return Text(
              AppStrings.of(context).yourBag.toUpperCase() + ' ($quantity)',
            );
          },
        ),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          return switch (state) {
            CartFailure() =>
              RetryPanel(onRetry: context.read<CartCubit>().load),
            CartLoading() => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.nearBlack,
                ),
              ),
            CartLoaded(:final items) when items.isEmpty => const _EmptyCart(),
            CartLoaded() => _CartContent(state: state),
          };
        },
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  const _CartContent({required this.state});

  final CartLoaded state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          sliver: SliverList.separated(
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const Divider(height: 28),
            itemBuilder: (context, index) =>
                _CartItemTile(item: state.items[index]),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _CartSummary(state: state),
          ),
        ),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 108,
          height: 118,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.concrete.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Image.network(
            item.product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              AppIcons.product,
              size: 42,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.brand,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                item.product.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                '${AppStrings.of(context).colorName(item.color)} · ${AppStrings.of(context).size} ${item.size}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.midGray,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QuantityButton(
                        icon: AppIcons.minus,
                        tooltip: AppStrings.of(context).isArabic
                            ? 'تقليل الكمية'
                            : 'Decrease quantity',
                        onPressed: () =>
                            context.read<CartCubit>().decrement(item),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 160),
                          child: Text(
                            '${item.quantity}',
                            key: ValueKey<int>(item.quantity),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      _QuantityButton(
                        icon: AppIcons.plus,
                        tooltip: AppStrings.of(context).isArabic
                            ? 'زيادة الكمية'
                            : 'Increase quantity',
                        onPressed: () =>
                            context.read<CartCubit>().increment(item),
                      ),
                    ],
                  ),
                  IconButton(
                    tooltip: AppStrings.of(context).isArabic
                        ? 'حذف المنتج'
                        : 'Remove item',
                    onPressed: () => context.read<CartCubit>().remove(item),
                    icon: Icon(AppIcons.trash, size: 21),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                '${item.lineTotal.toStringAsFixed(0)} EGP',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Tooltip(
        message: tooltip,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: AppColors.nearBlack,
            side: const BorderSide(color: AppColors.concrete),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.state});

  final CartLoaded state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        decoration: const BoxDecoration(
          color: AppColors.offWhite,
          border: Border(
            top: BorderSide(color: AppColors.concrete),
          ),
        ),
        child: BlocBuilder<PromotionsCubit, PromotionsState>(
          builder: (context, promotionState) {
            final ready = promotionState is PromotionsReady
                ? promotionState
                : const PromotionsReady();
            final discount = ready.discountFor(state.subtotal);
            final total = state.subtotal - discount;

            return Column(
              children: [
                _PromoCodeSection(
                  subtotal: state.subtotal,
                  state: ready,
                ),
                const SizedBox(height: 16),
                _SummaryRow(
                  label: AppStrings.of(context).subtotal.toUpperCase(),
                  value: '${state.subtotal.toStringAsFixed(0)} EGP',
                ),
                if (discount > 0) ...[
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label:
                        AppStrings.of(context).isArabic ? 'الخصم' : 'DISCOUNT',
                    value: '-${discount.toStringAsFixed(0)} EGP',
                  ),
                ],
                const SizedBox(height: 8),
                _SummaryRow(
                  label: AppStrings.of(context)
                      .deliveryTitle('Standard Delivery')
                      .toUpperCase(),
                  value: AppStrings.of(context).isArabic ? 'مجاني' : 'FREE',
                ),
                const Divider(height: 28),
                _SummaryRow(
                  label: AppStrings.of(context).total.toUpperCase(),
                  value: '${total.toStringAsFixed(0)} EGP',
                  emphasized: true,
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                      minWidth: double.infinity, minHeight: 52),
                  child: FilledButton(
                    onPressed: () async {
                      await Navigator.of(context).pushNamed(Routes.checkout);
                      if (context.mounted) {
                        await context.read<CartCubit>().load();
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.acidLime,
                      foregroundColor: AppColors.nearBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      AppStrings.of(context).checkout.toUpperCase() + '  →',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PromoCodeSection extends StatefulWidget {
  const _PromoCodeSection({
    required this.subtotal,
    required this.state,
  });

  final double subtotal;
  final PromotionsReady state;

  @override
  State<_PromoCodeSection> createState() => _PromoCodeSectionState();
}

class _PromoCodeSectionState extends State<_PromoCodeSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final applied = widget.state.applied;

    if (applied != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.acidLime.withValues(alpha: 0.22),
          border: Border.all(color: AppColors.nearBlack),
        ),
        child: Row(
          children: [
            Icon(AppIcons.tag),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    applied.code,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    strings.promotionTitle(applied.title),
                    style: const TextStyle(
                      color: AppColors.midGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: context.read<PromotionsCubit>().clear,
              child: Text(strings.isArabic ? 'إزالة' : 'REMOVE'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: strings.isArabic ? 'كود الخصم' : 'PROMO CODE',
                  prefixIcon: Icon(AppIcons.tag),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: FilledButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  context.read<PromotionsCubit>().apply(
                        code: _controller.text,
                        subtotal: widget.subtotal,
                      );
                },
                child: Text(strings.isArabic ? 'تطبيق' : 'APPLY'),
              ),
            ),
          ],
        ),
        if (widget.state.message != null) ...[
          const SizedBox(height: 7),
          Text(
            strings.promotionMessage(widget.state.message!),
            style: TextStyle(
              fontSize: 11,
              color: widget.state.hasError
                  ? Colors.red.shade700
                  : AppColors.midGray,
            ),
          ),
        ],
        const SizedBox(height: 5),
        Text(
          strings.isArabic
              ? 'جرّب STREET10 أو NOVA500'
              : 'Try STREET10 or NOVA500',
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.midGray,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            )
        : Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            );

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(label, style: style),
          Text(value,
              style: style,
              textDirection: value.contains('EGP') ? TextDirection.ltr : null),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.bag, size: 54),
            const SizedBox(height: 18),
            Text(
              AppStrings.of(context).emptyBag,
              style: AppTheme.displayFor(context, fontSize: 28),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.of(context).isArabic
                  ? 'اختَر ستايلك من أحدث المجموعات.'
                  : 'Build your rotation from the latest drops.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: Navigator.of(context).pop,
              child: Text(AppStrings.of(context).keepShopping),
            ),
          ],
        ),
      ),
    );
  }
}
