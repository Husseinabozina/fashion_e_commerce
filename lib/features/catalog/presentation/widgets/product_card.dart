import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    super.key,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: ColoredBox(
                          color: AppColors.concrete.withValues(alpha: 0.45),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.checkroom_rounded, size: 48),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (product.isNew)
                    const Positioned(
                      left: 8,
                      top: 8,
                      child: _NewBadge(),
                    ),
                  const Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(Icons.favorite_border_rounded, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.brand,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  '${product.price.toStringAsFixed(0)} EGP',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (product.previousPrice case final oldPrice?) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${oldPrice.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.midGray,
                          decoration: TextDecoration.lineThrough,
                        ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.acidLime,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Text(
          'NEW',
          style: TextStyle(
            color: AppColors.nearBlack,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
