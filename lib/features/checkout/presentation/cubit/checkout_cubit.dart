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
import 'package:fashion_e_commerce/core/presentation/account_cubit.dart';
import '../../domain/entities/sandbox_payment.dart';
import '../../domain/services/sandbox_payments.dart';

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
    this.hasSubmissionError = false,
  });

  final List<CartItem> items;
  final CheckoutOptions options;
  final Promotion? promotion;
  final CheckoutStep step;
  final ShippingAddress? address;
  final DeliveryOption? delivery;
  final PaymentOption? payment;
  final bool isSubmitting;
  final bool hasSubmissionError;

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
    bool? hasSubmissionError,
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
      hasSubmissionError: hasSubmissionError ?? this.hasSubmissionError,
    );
  }
}

final class CheckoutCompleted extends CheckoutState {
  const CheckoutCompleted(this.receipt, {this.cartCleared = true});

  final OrderReceipt receipt;
  final bool cartCleared;
}

final class CheckoutPaymentPending extends CheckoutState {
  const CheckoutPaymentPending(this.review, this.session,
      {this.isChecking = false, this.message = 'ready'});
  final CheckoutReady review;
  final SandboxPaymentSession session;
  final bool isChecking;
  final String message;
}

final class CheckoutFailure extends CheckoutState {
  const CheckoutFailure(this.message);

  final String message;
}

class CheckoutCubit extends AccountCubit<CheckoutState> {
  CheckoutCubit(
      this._getCart,
      this._getCheckoutOptions,
      this._getAppliedPromotion,
      this._getDefaultAddress,
      this._placeOrder,
      this._clearCart,
      {String Function()? submissionIdFactory,
      bool Function(String)? isCurrentAccount,
      SandboxPayments? sandboxPayments})
      : _submissionIdFactory = submissionIdFactory,
        _isCurrentAccount = isCurrentAccount,
        _sandboxPayments = sandboxPayments,
        super(const CheckoutLoading());

  final GetCart _getCart;
  final GetCheckoutOptions _getCheckoutOptions;
  final GetAppliedPromotion _getAppliedPromotion;
  final GetDefaultAddress _getDefaultAddress;
  final PlaceOrder _placeOrder;
  final ClearCart _clearCart;
  final String Function()? _submissionIdFactory;
  String? _submissionId;
  final bool Function(String)? _isCurrentAccount;
  final SandboxPayments? _sandboxPayments;

  PlaceOrderRequest _request(CheckoutReady current,
          {SandboxPaymentSession? session}) =>
      PlaceOrderRequest(
        items: current.items,
        address: current.address!,
        delivery: current.delivery!,
        payment: current.payment!,
        promotion: current.promotion,
        idempotencyKey:
            session == null ? _submissionId : 'TEST-${session.invoiceId}',
        sandboxPayment: session?.receipt,
      );

  void leavePayment() {
    final current = state;
    if (current is CheckoutPaymentPending && !current.isChecking) {
      emit(current.review.copyWith(isSubmitting: false));
    }
  }

  Future<void> checkPayment() async {
    final current = state;
    if (current is! CheckoutPaymentPending || current.isChecking) return;
    emit(CheckoutPaymentPending(current.review, current.session,
        isChecking: true));
    try {
      final result = await _sandboxPayments!.check(current.session);
      if (isClosed) return;
      if (current.session.ownerId != null &&
          _isCurrentAccount?.call(current.session.ownerId!) == false) {
        throw StateError('Account changed during payment.');
      }
      if (result == SandboxPaymentStatus.paid) {
        await _completeOrder(current.review, session: current.session);
      } else {
        if (result == SandboxPaymentStatus.cancelled) {
          await _sandboxPayments.forget(current.session);
          if (isClosed) return;
        }
        emit(CheckoutPaymentPending(current.review, current.session,
            message: result.name));
      }
    } catch (_) {
      if (!isClosed) {
        emit(CheckoutPaymentPending(current.review, current.session,
            message: 'error'));
      }
    }
  }

  Future<void> load() async {
    _submissionId = _submissionIdFactory?.call();
    emit(const CheckoutLoading());

    try {
      final items = await _getCart();
      if (isClosed) return;
      if (items.isEmpty) {
        emit(const CheckoutFailure('Your bag is empty.'));
        return;
      }

      final options = await _getCheckoutOptions();
      final promotion = await _getAppliedPromotion();
      final defaultAddress = await _getDefaultAddress();

      if (isClosed) return;
      emit(
        CheckoutReady(
          items: items,
          options: options,
          promotion: promotion,
          address: defaultAddress?.address,
        ),
      );
    } catch (_) {
      if (!isClosed) {
        emit(const CheckoutFailure('Checkout could not be loaded.'));
      }
    }
  }

  void saveAddress(ShippingAddress address) {
    final current = state;
    if (current is! CheckoutReady || current.isSubmitting) return;

    emit(
      current.copyWith(
        address: address,
        step: CheckoutStep.delivery,
      ),
    );
  }

  void selectDelivery(DeliveryOption option) {
    final current = state;
    if (current is! CheckoutReady || current.isSubmitting) return;

    emit(
      current.copyWith(
        delivery: option,
        step: CheckoutStep.payment,
      ),
    );
  }

  void selectPayment(PaymentOption option) {
    final current = state;
    if (current is! CheckoutReady || current.isSubmitting) return;

    emit(
      current.copyWith(
        payment: option,
        step: CheckoutStep.review,
      ),
    );
  }

  void goBack() {
    final current = state;
    if (current is! CheckoutReady || current.isSubmitting) return;

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
        current.isSubmitting ||
        current.step != CheckoutStep.review ||
        current.address == null ||
        current.delivery == null ||
        current.payment == null) {
      return;
    }

    emit(current.copyWith(isSubmitting: true, hasSubmissionError: false));

    if (current.payment!.id == 'card' && _sandboxPayments != null) {
      try {
        final session = await _sandboxPayments.begin(_request(current));
        if (!isClosed) emit(CheckoutPaymentPending(current, session));
      } catch (_) {
        if (!isClosed) {
          emit(current.copyWith(isSubmitting: false, hasSubmissionError: true));
        }
      }
      return;
    }
    await _completeOrder(current);
  }

  Future<void> _completeOrder(CheckoutReady current,
      {SandboxPaymentSession? session}) async {
    final OrderReceipt receipt;
    try {
      receipt = await _placeOrder(
        _request(current, session: session),
      );
    } catch (_) {
      if (!isClosed) {
        emit(session == null
            ? current.copyWith(isSubmitting: false, hasSubmissionError: true)
            : CheckoutPaymentPending(current, session, message: 'saveError'));
      }
      return;
    }

    // Placement has succeeded: cleanup failure must never offer order retry.
    var cartCleared = true;
    try {
      if (receipt.ownerId != null &&
          _isCurrentAccount?.call(receipt.ownerId!) == false) {
        cartCleared = false;
      } else {
        await _clearCart();
      }
    } catch (_) {
      cartCleared = false;
    }
    if (!isClosed) emit(CheckoutCompleted(receipt, cartCleared: cartCleared));
    if (session != null) {
      try {
        await _sandboxPayments!.forget(session);
      } catch (_) {
        /* A retained invoice still maps to the same demo order ID. */
      }
    }
  }
}
