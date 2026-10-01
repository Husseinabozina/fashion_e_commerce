import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/change_cart_quantity.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/get_cart.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/remove_cart_item.dart';
import 'package:fashion_e_commerce/core/presentation/account_cubit.dart';

sealed class CartState {
  const CartState();
}

final class CartLoading extends CartState {
  const CartLoading();
}

final class CartLoaded extends CartState {
  const CartLoaded(this.items);

  final List<CartItem> items;

  double get subtotal {
    return items.fold<double>(
      0,
      (total, item) => total + item.lineTotal,
    );
  }

  int get totalQuantity {
    return items.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );
  }
}

final class CartFailure extends CartState {
  const CartFailure();
}

class CartCubit extends AccountCubit<CartState> {
  CartCubit(
    this._getCart,
    this._changeQuantity,
    this._removeCartItem,
  ) : super(const CartLoading());

  final GetCart _getCart;
  final ChangeCartQuantity _changeQuantity;
  final RemoveCartItem _removeCartItem;

  Future<void> load() async {
    try {
      emit(const CartLoading());
      emit(CartLoaded(await _getCart()));
    } catch (_) {
      emit(const CartFailure());
    }
  }

  Future<void> increment(CartItem item) async {
    try {
      emit(
        CartLoaded(
          await _changeQuantity(item.key, item.quantity + 1),
        ),
      );
    } catch (_) {
      emit(const CartFailure());
    }
  }

  Future<void> decrement(CartItem item) async {
    try {
      emit(
        CartLoaded(
          await _changeQuantity(item.key, item.quantity - 1),
        ),
      );
    } catch (_) {
      emit(const CartFailure());
    }
  }

  Future<void> remove(CartItem item) async {
    try {
      emit(CartLoaded(await _removeCartItem(item.key)));
    } catch (_) {
      emit(const CartFailure());
    }
  }
}
