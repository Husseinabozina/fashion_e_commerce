import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/change_cart_quantity.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/get_cart.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/remove_cart_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class CartCubit extends Cubit<CartState> {
  CartCubit(
    this._getCart,
    this._changeQuantity,
    this._removeCartItem,
  ) : super(const CartLoading());

  final GetCart _getCart;
  final ChangeCartQuantity _changeQuantity;
  final RemoveCartItem _removeCartItem;

  Future<void> load() async {
    emit(const CartLoading());
    emit(CartLoaded(await _getCart()));
  }

  Future<void> increment(CartItem item) async {
    emit(
      CartLoaded(
        await _changeQuantity(item.key, item.quantity + 1),
      ),
    );
  }

  Future<void> decrement(CartItem item) async {
    emit(
      CartLoaded(
        await _changeQuantity(item.key, item.quantity - 1),
      ),
    );
  }

  Future<void> remove(CartItem item) async {
    emit(CartLoaded(await _removeCartItem(item.key)));
  }
}
