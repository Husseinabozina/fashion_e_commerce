import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/brands/presentation/cubit/brand_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrandPage extends StatelessWidget {
  const BrandPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<BrandCubit, BrandState>(
          builder: (context, state) {
            return switch (state) {
              BrandLoading() => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.nearBlack,
                  ),
                ),
              BrandFailure(:final message) => Center(
                  child: Text(AppStrings.of(context).loadFailure(message))),
              BrandReady() => _BrandContent(state: state),
            };
          },
        ),
      ),
    );
  }
}

class _BrandContent extends StatelessWidget {
  const _BrandContent({required this.state});

  final BrandReady state;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.nearBlack,
            padding: const EdgeInsets.fromLTRB(12, 8, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.white,
                  ),
                  icon: Icon(AppIcons.arrowLeft),
                ),
                const SizedBox(height: 28),
                Text(
                  state.brand.name,
                  style: AppTheme.displayFor(
                    context,
                    fontSize: 48,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  strings.brandCopy(state.brand.tagline),
                  style: const TextStyle(
                    color: AppColors.concrete,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  strings.brandCopy(state.brand.description),
                  style: const TextStyle(
                    color: AppColors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 48,
                  child: state.isFollowing
                      ? OutlinedButton.icon(
                          onPressed: context.read<BrandCubit>().toggleFollow,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            side: const BorderSide(color: AppColors.white),
                          ),
                          icon: Icon(AppIcons.check),
                          label: Text(
                            strings.isArabic ? 'تتابع العلامة' : 'FOLLOWING',
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: context.read<BrandCubit>().toggleFollow,
                          icon: Icon(AppIcons.plus),
                          label: Text(
                            strings.isArabic ? 'تابع العلامة' : 'FOLLOW BRAND',
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              strings.isArabic
                  ? 'أحدث منتجات ' + state.brand.name
                  : 'NEW FROM ' + state.brand.name,
              style: AppTheme.displayFor(context, fontSize: 28),
            ),
          ),
        ),
        if (state.products.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                strings.isArabic
                    ? 'لا توجد منتجات حاليًا.'
                    : 'NO PRODUCTS AVAILABLE.',
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
            sliver: SliverList.separated(
              itemCount: state.products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _BrandProductRow(product: state.products[index]);
              },
            ),
          ),
      ],
    );
  }
}

class _BrandProductRow extends StatelessWidget {
  const _BrandProductRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        Routes.productDetails,
        arguments: product.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        color: AppColors.white,
        child: Row(
          children: [
            Container(
              width: 92,
              height: 102,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.concrete.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.network(
                product.imageUrl,
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
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppStrings.of(context)
                        .categoryName(product.category)
                        .toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.midGray,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.price.toStringAsFixed(0) + ' EGP',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Icon(AppIcons.arrowRight),
          ],
        ),
      ),
    );
  }
}
