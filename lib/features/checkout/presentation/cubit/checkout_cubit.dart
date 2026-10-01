import 'package:fashion_e_commerce/features/addresses/domain/usecases/get_default_address.dart';
import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/clear_cart.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/get_cart.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/checkout_options.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/delivery_option.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/order_receipt.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/payment_option.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/place_order_request.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/shipping_address.dart';
import 'package:fashion_e_commerce/features/checkout/domain/usecases/get_checkout_options.dart';
import 'package:fashion_e_commerce/features/checkout/domain/usecases/place_order.dart';
import 'package:fashion_e_commerce/features/promotions/domain/entities/promotion.dart';
import 'package:fashion_e_commerce/features/promotions/domain/usecases/get_applied_promotion.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CheckoutStep { address, delivery, payment, review }

sealed class CheckoutState {
  const CheckoutState();
}

final class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

final class CheckoutReady extends CheckoutState {
  const CheckoutReady({
    required this.items,
    required this.options,
    this.promotion,
    this.step = CheckoutStep.address,
    this.address,
    this.delivery,
    this.payment,
    this.isSubmitting = false,
  });

  final List<CartItem> items;
  final CheckoutOptions options;
  final Promotion? promotion;
  final CheckoutStep step;
  final ShippingAddress? address;
  final DeliveryOption? delivery;
  final PaymentOption? payment;
  final bool isSubmitting;

  double get subtotal {
    return items.fold<double>(
      0,
      (sum, item) => sum + item.lineTotal,
    );
  }

  double get discount => promotion?.discountFor(subtotal) ?? 0;

  double get total => subtotal - discount + (delivery?.price ?? 0);

  CheckoutReady copyWith({
    CheckoutStep? step,
    ShippingAddress? address,
    DeliveryOption? delivery,
    PaymentOption? payment,
    bool? isSubmitting,
  }) {
    return CheckoutReady(
      items: items,
      options: options,
      promotion: promotion,
      step: step ?? this.step,
      address: address ?? this.address,
      delivery: delivery ?? this.delivery,
      payment: payment ?? this.payment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final class CheckoutCompleted extends CheckoutState {
  const CheckoutCompleted(this.receipt);

  final OrderReceipt receipt;
}

final class CheckoutFailure extends CheckoutState {
  const CheckoutFailure(this.message);

  final String message;
}

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(
    this._getCart,
    this._getCheckoutOptions,
    this._getAppliedPromotion,
    this._getDefaultAddress,
    this._placeOrder,
    this._clearCart,
  ) : super(const CheckoutLoading());

  final GetCart _getCart;
  final GetCheckoutOptions _getCheckoutOptions;
  final GetAppliedPromotion _getAppliedPromotion;
  final GetDefaultAddress _getDefaultAddress;
  final PlaceOrder _placeOrder;
  final ClearCart _clearCart;

  Future<void> load() async {
    emit(const CheckoutLoading());

    try {
      final items = await _getCart();
      if (items.isEmpty) {
        emit(const CheckoutFailure('Your bag is empty.'));
        return;
      }

      final options = await _getCheckoutOptions();
      final promotion = await _getAppliedPromotion();
      final defaultAddress = await _getDefaultAddress();

      emit(
        CheckoutReady(
          items: items,
          options: options,
          promotion: promotion,
          address: defaultAddress?.address,
        ),
      );
    } catch (_) {
      emit(const CheckoutFailure('Checkout could not be loaded.'));
    }
  }

  void saveAddress(ShippingAddress address) {
    final current = state;
    if (current is! CheckoutReady) return;

    emit(
      current.copyWith(
        address: address,
        step: CheckoutStep.delivery,
      ),
    );
  }

  void selectDelivery(DeliveryOption option) {
    final current = state;
    if (current is! CheckoutReady) return;

    emit(
      current.copyWith(
        delivery: option,
        step: CheckoutStep.payment,
      ),
    );
  }

  void selectPayment(PaymentOption option) {
    final current = state;
    if (current is! CheckoutReady) return;

    emit(
      current.copyWith(
        payment: option,
        step: CheckoutStep.review,
      ),
    );
  }

  void goBack() {
    final current = state;
    if (current is! CheckoutReady) return;

    final previous = switch (current.step) {
      CheckoutStep.address => CheckoutStep.address,
      CheckoutStep.delivery => CheckoutStep.address,
      CheckoutStep.payment => CheckoutStep.delivery,
      CheckoutStep.review => CheckoutStep.payment,
    };

    emit(current.copyWith(step: previous));
  }

  Future<void> submitOrder() async {
    final current = state;
    if (current is! CheckoutReady ||
        current.address == null ||
        current.delivery == null ||
        current.payment == null) {
      return;
    }

    emit(current.copyWith(isSubmitting: true));

    try {
      final receipt = await _placeOrder(
        PlaceOrderRequest(
          items: current.items,
          address: current.address!,
          delivery: current.delivery!,
          payment: current.payment!,
          promotion: current.promotion,
        ),
      );

      await _clearCart();
      emit(CheckoutCompleted(receipt));
    } catch (_) {
      emit(const CheckoutFailure('Order could not be placed.'));
    }
  }
}
