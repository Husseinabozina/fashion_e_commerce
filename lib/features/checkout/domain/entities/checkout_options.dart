import 'package:fashion_e_commerce/features/checkout/domain/entities/delivery_option.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/payment_option.dart';

class CheckoutOptions {
  const CheckoutOptions({
    required this.deliveryOptions,
    required this.paymentOptions,
  });

  final List<DeliveryOption> deliveryOptions;
  final List<PaymentOption> paymentOptions;
}
