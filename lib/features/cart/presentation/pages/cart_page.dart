import 'package:fashion_e_commerce/core/config/app_theme.dart';
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
            CartLoading() => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.nearBlack,
                ),
              ),
            CartLoaded(:final items) when items.isEmpty =>
              const _EmptyCart(),
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
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const Divider(height: 28),
            itemBuilder: (context, index) {
              return _CartItemTile(item: state.items[index]);
            },
          ),
        ),
        _CartSummary(state: state),
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
            errorBuilder: (_, __, ___) => const Icon(
              Icons.checkroom_rounded,
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
                '${item.color} · SIZE ${item.size}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.midGray,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onPressed: () => context.read<CartCubit>().decrement(item),
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
                    icon: Icons.add,
                    onPressed: () => context.read<CartCubit>().increment(item),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.read<CartCubit>().remove(item),
                    icon: const Icon(Icons.delete_outline_rounded, size: 21),
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
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
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
                label: AppStrings.of(context).isArabic
                    ? 'الخصم'
                    : 'DISCOUNT',
                value: '-${discount.toStringAsFixed(0)} EGP',
              ),
            ],
            const SizedBox(height: 8),
            _SummaryRow(
              label: AppStrings.of(context).delivery.toUpperCase(),
              value: AppStrings.of(context).isArabic ? 'مجاني' : 'FREE',
            ),
            const Divider(height: 28),
            _SummaryRow(
              label: AppStrings.of(context).total.toUpperCase(),
              value: '${total.toStringAsFixed(0)} EGP',
              emphasized: true,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pushNamed(Routes.checkout),
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
            const Icon(Icons.local_offer_outlined),
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
                    applied.title,
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
                  hintText: strings.isArabic
                      ? 'كود الخصم'
                      : 'PROMO CODE',
                  prefixIcon: const Icon(Icons.local_offer_outlined),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () {
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
            widget.state.message!,
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

    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
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
            const Icon(Icons.shopping_bag_outlined, size: 54),
            const SizedBox(height: 18),
            Text(
              AppStrings.of(context).emptyBag,
              style: AppTheme.displayFor(context, fontSize: 28),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Build your rotation from the latest drops.',
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
