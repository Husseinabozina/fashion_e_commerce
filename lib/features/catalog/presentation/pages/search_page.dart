import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/search_cubit.dart';
import 'package:fashion_e_commerce/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.autofocus = true});

  final bool autofocus;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context).search.toUpperCase()),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: TextField(
                controller: _controller,
                autofocus: widget.autofocus,
                onChanged: context.read<SearchCubit>().updateQuery,
                decoration: InputDecoration(
                  hintText: AppStrings.of(context).searchHint,
                  prefixIcon: Icon(AppIcons.search),
                ),
              ),
            ),
            BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state is! SearchReady) {
                  return const SizedBox.shrink();
                }

                return _SearchToolbar(state: state);
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  return switch (state) {
                    SearchLoading() => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.nearBlack,
                        ),
                      ),
                    SearchFailure(:final message) => Center(
                        child:
                            Text(AppStrings.of(context).loadFailure(message)),
                      ),
                    SearchReady(:final products) when products.isEmpty =>
                      const _NoResults(),
                    SearchReady() => _SearchGrid(state: state),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchToolbar extends StatelessWidget {
  const _SearchToolbar({required this.state});

  final SearchReady state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          52 + (MediaQuery.textScalerOf(context).scale(20) - 20).clamp(0, 60),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        children: [
          OutlinedButton.icon(
            onPressed: () => _showFilters(context, state),
            icon: Icon(AppIcons.filter, size: 17),
            label: Text(
              state.criteria.hasFilters
                  ? AppStrings.of(context).filters + ' •'
                  : AppStrings.of(context).filters,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _showSort(context, state.criteria.sort),
            icon: Icon(AppIcons.sort, size: 17),
            label: Text(AppStrings.of(context).sort),
          ),
          if (state.criteria.category case final category?) ...[
            const SizedBox(width: 8),
            InputChip(
              label: Text(AppStrings.of(context).categoryName(category)),
              onDeleted: () => context.read<SearchCubit>().setCategory(null),
            ),
          ],
          if (state.criteria.brand case final brand?) ...[
            const SizedBox(width: 8),
            InputChip(
              label: Text(brand),
              onDeleted: () => context.read<SearchCubit>().setBrand(null),
            ),
          ],
        ],
      ),
    );
  }

  void _showFilters(BuildContext context, SearchReady state) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<SearchCubit>(),
        child: _FilterSheet(state: state),
      ),
    );
  }

  void _showSort(BuildContext context, ProductSort selected) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: context.read<SearchCubit>(),
        child: _SortSheet(selected: selected),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({required this.state});

  final SearchReady state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(
                  AppStrings.of(context).filters,
                  style: AppTheme.displayFor(context, fontSize: 28),
                )),
                TextButton(
                  onPressed: () {
                    context.read<SearchCubit>().clearFilters();
                    Navigator.of(context).pop();
                  },
                  child: Text(AppStrings.of(context).clear),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              AppStrings.of(context).category,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.categories.map((category) {
                return ChoiceChip(
                  label: Text(AppStrings.of(context).categoryName(category)),
                  selected: state.criteria.category == category,
                  showCheckmark: false,
                  onSelected: (_) {
                    context.read<SearchCubit>().setCategory(category);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            Text(
              AppStrings.of(context).brand,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.brands.map((brand) {
                return ChoiceChip(
                  label: Text(brand),
                  selected: state.criteria.brand == brand,
                  showCheckmark: false,
                  onSelected: (_) {
                    context.read<SearchCubit>().setBrand(brand);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ],
        )),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.selected});

  final ProductSort selected;

  @override
  Widget build(BuildContext context) {
    const options = <ProductSort, String>{
      ProductSort.recommended: 'Recommended',
      ProductSort.newest: 'Newest first',
      ProductSort.priceLowToHigh: 'Price: low to high',
      ProductSort.priceHighToLow: 'Price: high to low',
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.of(context).sort,
              style: AppTheme.displayFor(context, fontSize: 28),
            ),
            const SizedBox(height: 10),
            ...options.entries.map(
              (entry) => RadioListTile<ProductSort>(
                value: entry.key,
                groupValue: selected,
                title: Text(AppStrings.of(context).sortOption(entry.value)),
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  if (value == null) return;
                  context.read<SearchCubit>().setSort(value);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class _SearchGrid extends StatelessWidget {
  const _SearchGrid({required this.state});

  final SearchReady state;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
        mainAxisExtent: (MediaQuery.sizeOf(context).width - 44) / 2 / .62 +
            (MediaQuery.textScalerOf(context).scale(100) - 100).clamp(0, 200),
      ),
      itemCount: state.products.length,
      itemBuilder: (context, index) {
        return _SearchProductTile(product: state.products[index]);
      },
    );
  }
}

class _SearchProductTile extends StatelessWidget {
  const _SearchProductTile({required this.product});

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
                  child: Hero(
                    tag: 'product-${product.id}',
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
                ),
                if (product.isNew)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: ColoredBox(
                      color: AppColors.acidLime,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 4),
                        child: Text(
                          AppStrings.of(context).newLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: BlocBuilder<WishlistCubit, WishlistState>(
                    builder: (context, state) {
                      final saved =
                          state is WishlistLoaded && state.contains(product.id);
                      return IconButton(
                        tooltip: saved
                            ? AppStrings.of(context).removeSavedProduct
                            : AppStrings.of(context).saveProduct,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.nearBlack,
                        ),
                        onPressed: () {
                          context.read<WishlistCubit>().toggle(product);
                        },
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            saved ? AppIcons.savedActive : AppIcons.saved,
                            key: ValueKey<bool>(saved),
                          ),
                        ),
                      );
                    },
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

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.search, size: 52),
            const SizedBox(height: 16),
            Text(
              AppStrings.of(context).noMatch,
              style: AppTheme.displayFor(context, fontSize: 30),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.of(context).tryAnother,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
