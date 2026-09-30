import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

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
        title: const Text('SEARCH'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: context.read<SearchCubit>().updateQuery,
                decoration: const InputDecoration(
                  hintText: 'Search products, brands, categories...',
                  prefixIcon: Icon(Icons.search_rounded),
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
                        child: Text(message),
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
      height: 52,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        children: [
          OutlinedButton.icon(
            onPressed: () => _showFilters(context, state),
            icon: const Icon(Icons.tune_rounded, size: 17),
            label: Text(
              state.criteria.hasFilters ? 'FILTERS •' : 'FILTERS',
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _showSort(context, state.criteria.sort),
            icon: const Icon(Icons.swap_vert_rounded, size: 17),
            label: const Text('SORT'),
          ),
          if (state.criteria.category case final category?) ...[
            const SizedBox(width: 8),
            InputChip(
              label: Text(category),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'FILTERS',
                  style: AppTheme.display(fontSize: 28),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    context.read<SearchCubit>().clearFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('CLEAR'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'CATEGORY',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.categories.map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: state.criteria.category == category,
                  onSelected: (_) {
                    context.read<SearchCubit>().setCategory(category);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            const Text(
              'BRAND',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.brands.map((brand) {
                return ChoiceChip(
                  label: Text(brand),
                  selected: state.criteria.brand == brand,
                  onSelected: (_) {
                    context.read<SearchCubit>().setBrand(brand);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ],
        ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SORT BY',
              style: AppTheme.display(fontSize: 28),
            ),
            const SizedBox(height: 10),
            ...options.entries.map(
              (entry) => RadioListTile<ProductSort>(
                value: entry.key,
                groupValue: selected,
                title: Text(entry.value),
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  if (value == null) return;
                  context.read<SearchCubit>().setSort(value);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
        childAspectRatio: 0.62,
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
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.checkroom_rounded, size: 42),
                        ),
                      ),
                    ),
                  ),
                ),
                if (product.isNew)
                  const Positioned(
                    left: 8,
                    top: 8,
                    child: ColoredBox(
                      color: AppColors.acidLime,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                const Positioned(
                  right: 8,
                  top: 8,
                  child: Icon(Icons.favorite_border_rounded),
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
            const Icon(Icons.search_off_rounded, size: 52),
            const SizedBox(height: 16),
            Text(
              'NO MATCH.',
              style: AppTheme.display(fontSize: 30),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try another keyword or clear your filters.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
