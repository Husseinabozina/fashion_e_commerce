import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/product_details_cubit.dart';
import 'package:fashion_e_commerce/features/recently_viewed/presentation/cubit/recently_viewed_cubit.dart';
import 'package:fashion_e_commerce/features/reviews/domain/entities/product_review.dart';
import 'package:fashion_e_commerce/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<ProductDetailsCubit, ProductDetailsState>(
          listenWhen: (previous, current) {
            if (current is! ProductDetailsReady) return false;
            if (previous is! ProductDetailsReady) return true;
            return previous.product.id != current.product.id;
          },
          listener: (context, state) {
            if (state is ProductDetailsReady) {
              context.read<RecentlyViewedCubit>().track(state.product);
            }
          },
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
                      child: Icon(AppIcons.product, size: 72),
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
                        InkWell(
                          onTap: () => Navigator.of(context).pushNamed(
                            Routes.brand,
                            arguments: product.brand,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  product.brand,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                AppIcons.arrowRight,
                                size: 14,
                              ),
                            ],
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
                            ? AppIcons.notificationsActive
                            : AppIcons.notifications,
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
              const SizedBox(height: 28),
              _CompleteTheLookSection(state: state),
              const SizedBox(height: 28),
              _ReviewsSection(state: state),
              const SizedBox(height: 28),
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
          icon: Icon(AppIcons.arrowLeft),
        ),
        const Spacer(),
        Icon(AppIcons.share),
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
                  saved ? AppIcons.savedActive : AppIcons.saved,
                  key: ValueKey<bool>(saved),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.cart),
          icon: Icon(AppIcons.bag),
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


class _CompleteTheLookSection extends StatelessWidget {
  const _CompleteTheLookSection({required this.state});

  final ProductDetailsReady state;

  @override
  Widget build(BuildContext context) {
    if (state.lookProducts.isEmpty) return const SizedBox.shrink();

    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.isArabic ? 'أكمل الإطلالة' : 'COMPLETE THE LOOK',
          style: AppTheme.displayFor(context, fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          strings.isArabic
              ? 'اختر القطع والمقاسات ثم أضف المجموعة للحقيبة.'
              : 'Pick the pieces and sizes, then add the selected look in one move.',
          style: const TextStyle(
            color: AppColors.midGray,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        ...state.lookProducts.map(
          (product) => _LookPieceCard(
            product: product,
            selected: state.selectedLookIds.contains(product.id),
            selectedSize: state.lookSizes[product.id],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              strings.isArabic ? 'إجمالي المختار' : 'SELECTED TOTAL',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Text(
              state.lookTotal.toStringAsFixed(0) + ' EGP',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: state.canAddLook
                ? () async {
                    final added = await context
                        .read<ProductDetailsCubit>()
                        .addSelectedLookToCart();

                    if (!context.mounted || added == 0) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          strings.isArabic
                              ? 'تمت إضافة ' +
                                  added.toString() +
                                  ' قطع إلى الحقيبة.'
                              : added.toString() +
                                  ' pieces added to your bag.',
                        ),
                        action: SnackBarAction(
                          label: strings.viewBag,
                          onPressed: () {
                            Navigator.of(context).pushNamed(Routes.cart);
                          },
                        ),
                      ),
                    );
                  }
                : null,
            icon: Icon(AppIcons.bagOpen),
            label: Text(
              strings.isArabic
                  ? 'أضف القطع المختارة'
                  : 'ADD SELECTED TO BAG',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        if (!state.canAddLook) ...[
          const SizedBox(height: 8),
          Text(
            strings.isArabic
                ? 'اختر مقاسًا لكل قطعة محددة.'
                : 'Choose a size for every selected piece.',
            style: const TextStyle(
              color: AppColors.midGray,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

class _LookPieceCard extends StatelessWidget {
  const _LookPieceCard({
    required this.product,
    required this.selected,
    required this.selectedSize,
  });

  final Product product;
  final bool selected;
  final String? selectedSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: selected ? 1 : 0.55,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: selected ? AppColors.nearBlack : AppColors.concrete,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LookSelectionBox(
                  selected: selected,
                  onTap: () {
                    context
                        .read<ProductDetailsCubit>()
                        .toggleLookProduct(product.id);
                  },
                ),
                const SizedBox(width: 10),
                Container(
                  width: 72,
                  height: 78,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.concrete.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(AppIcons.product),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.brand,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.price.toStringAsFixed(0) + ' EGP',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      Routes.productDetails,
                      arguments: product.id,
                    );
                  },
                  icon: Icon(AppIcons.arrowRight),
                ),
              ],
            ),
            if (selected) ...[
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: product.sizes
                      .where(product.isSizeAvailable)
                      .map(
                        (size) => ChoiceChip(
                          label: Text(size),
                          selected: selectedSize == size,
                          showCheckmark: false,
                          onSelected: (_) {
                            context
                                .read<ProductDetailsCubit>()
                                .selectLookSize(product.id, size);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class _LookSelectionBox extends StatelessWidget {
  const _LookSelectionBox({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.nearBlack : AppColors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.nearBlack,
              width: 1.5,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 140),
            child: selected
                ? Icon(
                    AppIcons.check,
                    key: const ValueKey<String>('selected'),
                    color: AppColors.white,
                    size: 16,
                  )
                : const SizedBox.shrink(
                    key: ValueKey<String>('unselected'),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.state});

  final ProductDetailsReady state;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final fit = state.dominantFit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                strings.isArabic ? 'التقييمات' : 'REVIEWS',
                style: AppTheme.displayFor(context, fontSize: 28),
              ),
            ),
            OutlinedButton(
              onPressed: () => _showReviewSheet(context),
              child: Text(
                strings.isArabic ? 'اكتب تقييمًا' : 'WRITE REVIEW',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (state.reviews.isEmpty)
          Text(
            strings.isArabic
                ? 'لا توجد تقييمات بعد. كن أول من يقيّم المنتج.'
                : 'No reviews yet. Be the first to review this product.',
            style: const TextStyle(color: AppColors.midGray),
          )
        else ...[
          Row(
            children: [
              Text(
                state.averageRating.toStringAsFixed(1),
                style: AppTheme.displayFor(context, fontSize: 34),
              ),
              const SizedBox(width: 10),
              _Stars(rating: state.averageRating.round()),
              const Spacer(),
              Text(
                strings.isArabic
                    ? state.reviews.length.toString() + ' تقييم'
                    : state.reviews.length.toString() + ' reviews',
                style: const TextStyle(color: AppColors.midGray),
              ),
            ],
          ),
          if (fit != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              color: AppColors.concrete.withValues(alpha: 0.35),
              child: Text(
                strings.isArabic
                    ? 'رأي الأغلبية في المقاس: ' + _fitLabel(fit, true)
                    : 'Most shoppers say: ' + _fitLabel(fit, false),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          ...state.reviews.take(3).map(
                (review) => _ReviewCard(review: review),
              ),
        ],
      ],
    );
  }

  void _showReviewSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductDetailsCubit>(),
        child: const _WriteReviewSheet(),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ProductReview review;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.concrete),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Stars(rating: review.rating),
              const Spacer(),
              if (review.verifiedPurchase)
                Text(
                  strings.isArabic ? 'شراء موثّق' : 'VERIFIED PURCHASE',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.authorName,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(review.comment),
          const SizedBox(height: 8),
          Text(
            (strings.isArabic ? 'المقاس: ' : 'FIT: ') +
                _fitLabel(review.fit, strings.isArabic),
            style: const TextStyle(
              color: AppColors.midGray,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? AppIcons.starFilled : AppIcons.star,
          size: 17,
        ),
      ),
    );
  }
}

class _WriteReviewSheet extends StatefulWidget {
  const _WriteReviewSheet();

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  final _comment = TextEditingController();
  int _rating = 5;
  FitFeedback _fit = FitFeedback.trueToSize;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.isArabic ? 'اكتب تقييمك' : 'WRITE YOUR REVIEW',
                style: AppTheme.displayFor(context, fontSize: 32),
              ),
              const SizedBox(height: 18),
              Row(
                children: List.generate(
                  5,
                  (index) => IconButton(
                    onPressed: () => setState(() => _rating = index + 1),
                    icon: Icon(
                      index < _rating
                          ? AppIcons.starFilled
                          : AppIcons.star,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                strings.isArabic ? 'كيف كان المقاس؟' : 'HOW DID IT FIT?',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              SegmentedButton<FitFeedback>(
                segments: [
                  ButtonSegment(
                    value: FitFeedback.runsSmall,
                    label: Text(_fitLabel(FitFeedback.runsSmall, strings.isArabic)),
                  ),
                  ButtonSegment(
                    value: FitFeedback.trueToSize,
                    label: Text(_fitLabel(FitFeedback.trueToSize, strings.isArabic)),
                  ),
                  ButtonSegment(
                    value: FitFeedback.runsLarge,
                    label: Text(_fitLabel(FitFeedback.runsLarge, strings.isArabic)),
                  ),
                ],
                selected: <FitFeedback>{_fit},
                onSelectionChanged: (value) {
                  setState(() => _fit = value.first);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _comment,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: strings.isArabic ? 'رأيك' : 'YOUR REVIEW',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () async {
                    final submitted = await context
                        .read<ProductDetailsCubit>()
                        .submitReview(
                          rating: _rating,
                          fit: _fit,
                          comment: _comment.text,
                        );
                    if (submitted && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    strings.isArabic ? 'إرسال التقييم' : 'SUBMIT REVIEW',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _fitLabel(FitFeedback fit, bool isArabic) {
  if (!isArabic) return fit.label;

  return switch (fit) {
    FitFeedback.runsSmall => 'أصغر من المعتاد',
    FitFeedback.trueToSize => 'مظبوط',
    FitFeedback.runsLarge => 'أكبر من المعتاد',
  };
}

class _ServiceStrip extends StatelessWidget {
  const _ServiceStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ServiceItem(
            icon: AppIcons.delivery,
            title: AppStrings.of(context).freeDelivery,
            subtitle: AppStrings.of(context).isArabic
                ? 'من 2 إلى 4 أيام عمل'
                : '2–4 business days',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ServiceItem(
            icon: AppIcons.returns,
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
                          textColor: AppColors.white,
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
