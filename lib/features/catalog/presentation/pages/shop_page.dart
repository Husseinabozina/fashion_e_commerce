import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/catalog_browse_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.shop.toUpperCase()),
        actions: [
          IconButton(
            tooltip: strings.search,
            onPressed: () => Navigator.of(context).pushNamed(Routes.search),
            icon: Icon(AppIcons.search),
          ),
          IconButton(
            tooltip: strings.viewBag,
            onPressed: () => Navigator.of(context).pushNamed(Routes.cart),
            icon: Icon(AppIcons.bag),
          ),
        ],
      ),
      body: BlocBuilder<CatalogBrowseCubit, CatalogBrowseState>(
        builder: (context, state) {
          return switch (state) {
            CatalogBrowseLoading() => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.nearBlack,
                ),
              ),
            CatalogBrowseFailure(:final message) =>
              Center(child: Text(AppStrings.of(context).loadFailure(message))),
            CatalogBrowseLoaded() => _ShopContent(state: state),
          };
        },
      ),
    );
  }
}

class _ShopContent extends StatelessWidget {
  const _ShopContent({required this.state});

  final CatalogBrowseLoaded state;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      children: [
        Text(
          strings.isArabic ? 'تسوّق\nبطريقتك.' : 'SHOP\nYOUR ROTATION.',
          style: AppTheme.displayFor(context, fontSize: 40),
        ),
        const SizedBox(height: 26),
        _SectionLabel(
          index: '01/',
          label: strings.category.toUpperCase(),
        ),
        const SizedBox(height: 10),
        ...state.categories.map(
          (category) => _BrowseRow(
            label: strings.categoryName(category),
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.search,
                arguments: ProductSearchCriteria(category: category),
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        _SectionLabel(
          index: '02/',
          label: strings.brand.toUpperCase(),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.brands
              .map(
                (brand) => ActionChip(
                  label: Text(brand),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      Routes.brand,
                      arguments: brand,
                    );
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 30),
        _SectionLabel(
          index: '03/',
          label: strings.newArrivals,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: ProductCard.carouselHeight(context),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return ProductCard(product: state.products[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.index,
    required this.label,
  });

  final String index;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          index,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        )),
      ],
    );
  }
}

class _BrowseRow extends StatelessWidget {
  const _BrowseRow({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.concrete),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Icon(AppIcons.arrowRight),
          ],
        ),
      ),
    );
  }
}
