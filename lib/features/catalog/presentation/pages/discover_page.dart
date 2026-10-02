import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/catalog_browse_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        backgroundColor: AppColors.nearBlack,
        foregroundColor: AppColors.white,
        title: Text(
          AppStrings.of(context).discover.toUpperCase(),
          style: const TextStyle(color: AppColors.white),
        ),
      ),
      body: BlocBuilder<CatalogBrowseCubit, CatalogBrowseState>(
        builder: (context, state) {
          return switch (state) {
            CatalogBrowseLoading() => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.acidLime,
                ),
              ),
            CatalogBrowseFailure(:final message) => Center(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            CatalogBrowseLoaded() => _DiscoverContent(state: state),
          };
        },
      ),
    );
  }
}

class _DiscoverContent extends StatelessWidget {
  const _DiscoverContent({required this.state});

  final CatalogBrowseLoaded state;

  @override
  Widget build(BuildContext context) {
    final products = state.products;
    if (products.isEmpty) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 34),
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.94, end: 1),
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: value,
                alignment: AlignmentDirectional.topStart,
                child: child,
              ),
            );
          },
          child: _DropRadar(product: products.first),
        ),
        const SizedBox(height: 34),
        Text(
          '01/ ' +
              (AppStrings.of(context).isArabic
                  ? 'اختيارات الأسبوع'
                  : 'THIS WEEK'),
          style: const TextStyle(
            color: AppColors.concrete,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppStrings.of(context).isArabic
              ? 'قطع تدخل\nفي كل إطلالة.'
              : 'BUILT FOR\nTHE ROTATION.',
          style: AppTheme.displayFor(
            context,
            fontSize: 39,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 18),
        ...products.skip(1).take(3).map(
              (product) => _DiscoverProduct(product: product),
            ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(18),
          color: AppColors.acidLime,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.of(context).isArabic
                      ? 'اعثر على القطعة التالية.'
                      : 'FIND YOUR NEXT PIECE.',
                  style: AppTheme.displayFor(
                    context,
                    fontSize: 25,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pushNamed(Routes.search),
                icon: Icon(AppIcons.arrowRight),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DropRadar extends StatelessWidget {
  const _DropRadar({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: AppColors.darkGray,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.nearBlack.withValues(alpha: 0.84),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: 16,
            top: 16,
            child: Container(
              color: AppColors.acidLime,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              child: Text(
                AppStrings.of(context).isArabic
                    ? 'رادار المجموعات'
                    : 'DROP RADAR',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: 16,
            end: 16,
            bottom: 18,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.brand,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        style: AppTheme.displayFor(
                          context,
                          fontSize: 30,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      Routes.productDetails,
                      arguments: product.id,
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.acidLime,
                    foregroundColor: AppColors.nearBlack,
                  ),
                  icon: Icon(AppIcons.arrowRight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverProduct extends StatelessWidget {
  const _DiscoverProduct({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        Routes.productDetails,
        arguments: product.id,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 92,
              height: 100,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: AppColors.darkGray,
              ),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  AppIcons.product,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    style: const TextStyle(
                      color: AppColors.concrete,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    product.price.toStringAsFixed(0) + ' EGP',
                    style: const TextStyle(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.arrowRight,
              color: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}
