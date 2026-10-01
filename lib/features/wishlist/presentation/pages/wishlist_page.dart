import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAVED'),
      ),
      body: BlocBuilder<WishlistCubit, WishlistState>(
        builder: (context, state) {
          return switch (state) {
            WishlistLoading() => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.nearBlack,
                ),
              ),
            WishlistLoaded(:final items) when items.isEmpty =>
              const _EmptyWishlist(),
            WishlistLoaded(:final items) => _WishlistGrid(items: items),
          };
        },
      ),
    );
  }
}

class _WishlistGrid extends StatelessWidget {
  const _WishlistGrid({required this.items});

  final List<Product> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
        childAspectRatio: 0.62,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _WishlistTile(product: items[index]);
      },
    );
  }
}

class _WishlistTile extends StatelessWidget {
  const _WishlistTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.productDetails,
          arguments: product.id,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.concrete.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(AppIcons.product, size: 42),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.offWhite,
                      foregroundColor: AppColors.nearBlack,
                    ),
                    onPressed: () {
                      context.read<WishlistCubit>().toggle(product);
                    },
                    icon: Icon(AppIcons.savedActive),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.brand,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${product.price.toStringAsFixed(0)} EGP',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.saved, size: 56),
            const SizedBox(height: 18),
            Text(
              'SAVE YOUR\nROTATION.',
              textAlign: TextAlign.center,
              style: AppTheme.display(fontSize: 32),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap the heart on products you want to come back to.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.home,
                  (route) => false,
                );
              },
              child: const Text('EXPLORE PRODUCTS'),
            ),
          ],
        ),
      ),
    );
  }
}
