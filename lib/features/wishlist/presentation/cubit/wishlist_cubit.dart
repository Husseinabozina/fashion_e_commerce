import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/wishlist/domain/usecases/get_wishlist.dart';
import 'package:fashion_e_commerce/features/wishlist/domain/usecases/toggle_wishlist.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class WishlistState {
  const WishlistState();
}

final class WishlistLoading extends WishlistState {
  const WishlistLoading();
}

final class WishlistLoaded extends WishlistState {
  const WishlistLoaded(this.items);

  final List<Product> items;

  bool contains(String productId) {
    return items.any((item) => item.id == productId);
  }
}

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit(
    this._getWishlist,
    this._toggleWishlist,
  ) : super(const WishlistLoading());

  final GetWishlist _getWishlist;
  final ToggleWishlist _toggleWishlist;

  Future<void> load() async {
    emit(const WishlistLoading());
    emit(WishlistLoaded(await _getWishlist()));
  }

  Future<void> toggle(Product product) async {
    emit(WishlistLoaded(await _toggleWishlist(product)));
  }
}
