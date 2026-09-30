import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/home_catalog.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const _StreetBottomNavigation(),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return switch (state) {
              HomeInitial() || HomeLoading() => const _HomeLoading(),
              HomeLoaded(:final catalog) => _HomeContent(catalog: catalog),
              HomeFailure(:final message) => _HomeError(message: message),
            };
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.catalog});

  final HomeCatalog catalog;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: context.read<HomeCubit>().load,
      color: AppColors.nearBlack,
      backgroundColor: AppColors.acidLime,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          const _TopBar(),
          const SizedBox(height: 18),
          const _SearchField(),
          const SizedBox(height: 14),
          _HeroDrop(catalog: catalog),
          const SizedBox(height: 28),
          const _SectionTitle(index: '01/', title: 'NEW ARRIVALS'),
          const SizedBox(height: 12),
          SizedBox(
            height: 268,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: catalog.newArrivals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return ProductCard(product: catalog.newArrivals[index]);
              },
            ),
          ),
          const SizedBox(height: 32),
          const _SectionTitle(index: '02/', title: 'SHOP BY CATEGORY'),
          const SizedBox(height: 12),
          ...catalog.categories.map(
            (category) => _CategoryRow(category: category),
          ),
          const SizedBox(height: 28),
          const _EditorialBlock(),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'NOVA_',
          style: AppTheme.display(fontSize: 26),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.search),
          icon: const Icon(Icons.search_rounded),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.wishlist),
          icon: const Icon(Icons.favorite_border_rounded),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.cart),
          icon: const Icon(Icons.shopping_bag_outlined),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(Routes.search),
      borderRadius: BorderRadius.circular(8),
      child: Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.nearBlack.withValues(alpha: 0.08),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search products, brands, drops...',
              style: TextStyle(
                color: AppColors.midGray,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _HeroDrop extends StatelessWidget {
  const _HeroDrop({required this.catalog});

  final HomeCatalog catalog;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 370,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -70,
            top: 55,
            width: 300,
            height: 240,
            child: Transform.rotate(
              angle: -0.15,
              child: Image.network(
                catalog.heroProduct.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 18,
            child: Text(
              'DROP\n026',
              style: AppTheme.display(
                fontSize: 62,
                color: AppColors.white,
              ),
            ),
          ),
          const Positioned(
            left: 16,
            bottom: 80,
            child: Text(
              'LIMITED RELEASE',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                fontSize: 12,
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 20,
            child: FilledButton.icon(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.acidLime,
                foregroundColor: AppColors.nearBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text(
                'SHOP THE DROP',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.index,
    required this.title,
  });

  final String index;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          index,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AppTheme.display(fontSize: 27),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('VIEW →'),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: AppColors.nearBlack.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const Icon(Icons.arrow_forward_rounded),
        ],
      ),
    );
  }
}

class _EditorialBlock extends StatelessWidget {
  const _EditorialBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      color: AppColors.darkGray,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '03/ STREET EDIT',
            style: TextStyle(
              color: AppColors.acidLime,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'NO RULES.\nJUST ROTATION.',
            style: AppTheme.display(
              fontSize: 39,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Curated streetwear essentials. Fresh drops, clean silhouettes, zero noise.',
            style: TextStyle(
              color: AppColors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('DISCOVER THE EDIT'),
          ),
        ],
      ),
    );
  }
}

class _StreetBottomNavigation extends StatelessWidget {
  const _StreetBottomNavigation();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        if (index == 1) {
          Navigator.of(context).pushNamed(Routes.search);
        } else if (index == 3) {
          Navigator.of(context).pushNamed(Routes.wishlist);
        } else if (index == 4) {
          Navigator.of(context).pushNamed(Routes.account);
        }
      },
      indicatorColor: Colors.transparent,
      backgroundColor: AppColors.offWhite,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          label: 'Shop',
        ),
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          label: 'Discover',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border_rounded),
          label: 'Saved',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Account',
        ),
      ],
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 10),
        Container(height: 28, width: 100, color: AppColors.concrete),
        const SizedBox(height: 24),
        Container(height: 46, color: AppColors.concrete),
        const SizedBox(height: 14),
        Container(height: 370, color: AppColors.darkGray),
        const SizedBox(height: 28),
        Container(height: 26, width: 180, color: AppColors.concrete),
      ],
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 40),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: context.read<HomeCubit>().load,
              child: const Text('TRY AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}
