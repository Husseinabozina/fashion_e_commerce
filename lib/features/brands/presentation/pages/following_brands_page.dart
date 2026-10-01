import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/brands/domain/entities/brand.dart';
import 'package:fashion_e_commerce/features/brands/presentation/cubit/following_brands_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowingBrandsPage extends StatelessWidget {
  const FollowingBrandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.isArabic ? 'العلامات المتابَعة' : 'FOLLOWING BRANDS',
        ),
      ),
      body: BlocBuilder<FollowingBrandsCubit, FollowingBrandsState>(
        builder: (context, state) {
          return switch (state) {
            FollowingBrandsLoading() => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.nearBlack,
                ),
              ),
            FollowingBrandsFailure(:final message) =>
              Center(child: Text(message)),
            FollowingBrandsLoaded(:final brands) when brands.isEmpty =>
              _EmptyFollowing(isArabic: strings.isArabic),
            FollowingBrandsLoaded(:final brands) =>
              _FollowingList(brands: brands),
          };
        },
      ),
    );
  }
}

class _FollowingList extends StatelessWidget {
  const _FollowingList({required this.brands});

  final List<Brand> brands;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: brands.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final brand = brands[index];

        return InkWell(
          onTap: () => Navigator.of(context).pushNamed(
            Routes.brand,
            arguments: brand.name,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  color: AppColors.nearBlack,
                  child: Text(
                    brand.name.substring(0, 1),
                    style: AppTheme.display(
                      fontSize: 22,
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
                        brand.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        brand.tagline,
                        style: const TextStyle(
                          color: AppColors.midGray,
                          fontSize: 11,
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
      },
    );
  }
}

class _EmptyFollowing extends StatelessWidget {
  const _EmptyFollowing({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.plus, size: 54),
            const SizedBox(height: 16),
            Text(
              isArabic
                  ? 'لسه مش بتتابع أي علامة.'
                  : 'NO BRANDS\nFOLLOWED YET.',
              textAlign: TextAlign.center,
              style: AppTheme.displayFor(context, fontSize: 31),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamed(Routes.shop),
              child: Text(isArabic ? 'استكشف العلامات' : 'EXPLORE BRANDS'),
            ),
          ],
        ),
      ),
    );
  }
}
