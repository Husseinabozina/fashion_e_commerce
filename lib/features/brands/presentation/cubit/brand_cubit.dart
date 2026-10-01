import 'package:fashion_e_commerce/features/brands/domain/entities/brand.dart';
import 'package:fashion_e_commerce/features/brands/domain/usecases/get_brand.dart';
import 'package:fashion_e_commerce/features/brands/domain/usecases/is_following_brand.dart';
import 'package:fashion_e_commerce/features/brands/domain/usecases/toggle_brand_follow.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/search_products.dart';
import 'package:fashion_e_commerce/core/presentation/account_cubit.dart';

sealed class BrandState {
  const BrandState();
}

final class BrandLoading extends BrandState {
  const BrandLoading();
}

final class BrandReady extends BrandState {
  const BrandReady({
    required this.brand,
    required this.products,
    required this.isFollowing,
  });

  final Brand brand;
  final List<Product> products;
  final bool isFollowing;

  BrandReady copyWith({
    bool? isFollowing,
  }) {
    return BrandReady(
      brand: brand,
      products: products,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

final class BrandFailure extends BrandState {
  const BrandFailure(this.message);

  final String message;
}

class BrandCubit extends AccountCubit<BrandState> {
  BrandCubit(
    this._getBrand,
    this._isFollowingBrand,
    this._toggleBrandFollow,
    this._searchProducts,
  ) : super(const BrandLoading());

  final GetBrand _getBrand;
  final IsFollowingBrand _isFollowingBrand;
  final ToggleBrandFollow _toggleBrandFollow;
  final SearchProducts _searchProducts;

  Future<void> load(String brandName) async {
    emit(const BrandLoading());

    try {
      final brand = await _getBrand(brandName);
      final products = await _searchProducts(
        ProductSearchCriteria(brand: brand.name),
      );
      final isFollowing = await _isFollowingBrand(brand.id);

      emit(
        BrandReady(
          brand: brand,
          products: products,
          isFollowing: isFollowing,
        ),
      );
    } catch (_) {
      emit(const BrandFailure('Brand could not be loaded.'));
    }
  }

  Future<void> toggleFollow() async {
    try {
      final current = state;
      if (current is! BrandReady) return;

      final isFollowing = await _toggleBrandFollow(current.brand.id);
      emit(current.copyWith(isFollowing: isFollowing));
    } catch (_) {
      emit(const BrandFailure('Brand could not be loaded.'));
    }
  }
}
