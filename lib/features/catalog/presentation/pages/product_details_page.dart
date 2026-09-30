import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/product_details_cubit.dart';
import 'package:fashion_e_commerce/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
          builder: (context, state) {
            return switch (state) {
              ProductDetailsLoading() => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.nearBlack,
                  ),
                ),
              ProductDetailsFailure(:final message) => Center(
                  child: Text(message),
                ),
              ProductDetailsReady() => _ProductDetailsContent(state: state),
            };
          },
        ),
      ),
    );
  }
}

class _ProductDetailsContent extends StatelessWidget {
  const _ProductDetailsContent({required this.state});

  final ProductDetailsReady state;

  Product get product => state.product;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _DetailsTopBar(product: product),
              const SizedBox(height: 10),
              Hero(
                tag: 'product-${product.id}',
                child: Container(
                  height: 340,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.concrete.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.checkroom_rounded, size: 72),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.brand,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          product.name,
                          style: AppTheme.displayFor(context, fontSize: 30),
                        ),
                      ],
                    ),
                  ),
                  if (product.isNew)
                    const ColoredBox(
                      color: AppColors.acidLime,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        child: Text(
                          'NEW',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${product.price.toStringAsFixed(0)} EGP',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 22),
              _LabelValue(
                label: AppStrings.of(context).color,
                value: state.selectedColor ?? 'Select',
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: product.colors.map((color) {
                  final selected = state.selectedColor == color;
                  return ChoiceChip(
                    label: Text(color),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: AppColors.nearBlack,
                    backgroundColor: AppColors.white,
                    labelStyle: TextStyle(
                      color:
                          selected ? AppColors.white : AppColors.nearBlack,
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide(
                      color: selected
                          ? AppColors.nearBlack
                          : AppColors.concrete,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onSelected: (_) {
                      context.read<ProductDetailsCubit>().selectColor(color);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    AppStrings.of(context).selectSize,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showSizeGuide(context),
                    child: Text(AppStrings.of(context).sizeGuide),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: product.sizes.map((size) {
                  final available = product.isSizeAvailable(size);
                  final selected = state.selectedSize == size;
                  final subscribed = state.subscribedSizes.contains(size);

                  if (!available) {
                    return ActionChip(
                      avatar: Icon(
                        subscribed
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                        size: 17,
                      ),
                      label: Text(
                        subscribed
                            ? size + ' · ' +
                                (AppStrings.of(context).isArabic
                                    ? 'تم التنبيه'
                                    : 'NOTIFY ON')
                            : size + ' · ' +
                                (AppStrings.of(context).isArabic
                                    ? 'نبّهني'
                                    : 'NOTIFY ME'),
                      ),
                      onPressed: subscribed
                          ? null
                          : () async {
                              final added = await context
                                  .read<ProductDetailsCubit>()
                                  .subscribeForSize(size);
                              if (!context.mounted || !added) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppStrings.of(context).isArabic
                                        ? 'سننبهك عندما يتوفر المقاس ' + size
                                        : 'We’ll notify you when size ' +
                                            size +
                                            ' is back.',
                                  ),
                                ),
                              );
                            },
                    );
                  }

                  return ChoiceChip(
                    label: Text(size),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: AppColors.acidLime,
                    backgroundColor: AppColors.white,
                    labelStyle: const TextStyle(
                      color: AppColors.nearBlack,
                      fontWeight: FontWeight.w900,
                    ),
                    side: BorderSide(
                      color: selected
                          ? AppColors.nearBlack
                          : AppColors.concrete,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onSelected: (_) {
                      context.read<ProductDetailsCubit>().selectSize(size);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _InfoRow(title: AppStrings.of(context).fit, value: product.fit),
              const Divider(height: 28),
              Text(
                product.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 24),
              const _ServiceStrip(),
            ],
          ),
        ),
        _AddToBagBar(state: state),
      ],
    );
  }

  void _showSizeGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.of(context).sizeGuide,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              const Text('40  ·  25.5 cm'),
              const Text('41  ·  26.0 cm'),
              const Text('42  ·  26.5 cm'),
              const Text('43  ·  27.5 cm'),
              const Text('44  ·  28.0 cm'),
            ],
          ),
        );
      },
    );
  }
}

class _DetailsTopBar extends StatelessWidget {
  const _DetailsTopBar({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const Spacer(),
        const Icon(Icons.share_outlined),
        const SizedBox(width: 18),
        BlocBuilder<WishlistCubit, WishlistState>(
          builder: (context, state) {
            final saved =
                state is WishlistLoaded && state.contains(product.id);
            return IconButton(
              onPressed: () {
                context.read<WishlistCubit>().toggle(product);
              },
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  key: ValueKey<bool>(saved),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.cart),
          icon: const Icon(Icons.shopping_bag_outlined),
        ),
      ],
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(
            text: '$label  ',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        Text(value),
      ],
    );
  }
}

class _ServiceStrip extends StatelessWidget {
  const _ServiceStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ServiceItem(
            icon: Icons.local_shipping_outlined,
            title: AppStrings.of(context).freeDelivery,
            subtitle: AppStrings.of(context).isArabic
                ? 'من 2 إلى 4 أيام عمل'
                : '2–4 business days',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ServiceItem(
            icon: Icons.keyboard_return_rounded,
            title: AppStrings.of(context).easyReturns,
            subtitle: AppStrings.of(context).isArabic
                ? 'خلال 14 يومًا'
                : 'Within 14 days',
          ),
        ),
      ],
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.midGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddToBagBar extends StatelessWidget {
  const _AddToBagBar({required this.state});

  final ProductDetailsReady state;

  @override
  Widget build(BuildContext context) {
    final canAdd = state.selectedSize != null;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          border: Border(
            top: BorderSide(
              color: AppColors.nearBlack.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: canAdd
                ? () async {
                    final added = await context
                        .read<ProductDetailsCubit>()
                        .addSelectedToCart();
                    if (!context.mounted || !added) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.nearBlack,
                        content: Text(
                          'Added ${state.product.name} · Size ${state.selectedSize}',
                          style: const TextStyle(color: AppColors.white),
                        ),
                        action: SnackBarAction(
                          label: AppStrings.of(context).viewBag,
                          textColor: AppColors.acidLime,
                          onPressed: () {
                            Navigator.of(context).pushNamed(Routes.cart);
                          },
                        ),
                      ),
                    );
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.acidLime,
              disabledBackgroundColor: AppColors.concrete,
              foregroundColor: AppColors.nearBlack,
              disabledForegroundColor: AppColors.midGray,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                canAdd
                    ? AppStrings.of(context).addToBag
                    : AppStrings.of(context).selectASize,
                key: ValueKey<bool>(canAdd),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
