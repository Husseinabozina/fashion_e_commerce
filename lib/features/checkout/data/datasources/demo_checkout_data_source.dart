import 'package:fashion_e_commerce/features/checkout/data/datasources/checkout_data_source.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/checkout_options.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/delivery_option.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/order_receipt.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/payment_option.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/place_order_request.dart';

class DemoCheckoutDataSource implements CheckoutDataSource {
  @override
  Future<CheckoutOptions> fetchOptions() async {
    return const CheckoutOptions(
      deliveryOptions: <DeliveryOption>[
        DeliveryOption(
          id: 'standard',
          title: 'Standard Delivery',
          eta: '2–4 business days',
          price: 0,
        ),
        DeliveryOption(
          id: 'express',
          title: 'Express Delivery',
          eta: 'Next business day',
          price: 90,
        ),
      ],
      paymentOptions: <PaymentOption>[
        PaymentOption(
          id: 'card',
          title: 'Card',
          subtitle: 'Visa · Mastercard',
        ),
        PaymentOption(
          id: 'cod',
          title: 'Cash on Delivery',
          subtitle: 'Pay when your order arrives',
        ),
        PaymentOption(
          id: 'wallet',
          title: 'Wallet',
          subtitle: 'Digital wallet',
        ),
      ],
    );
  }

  @override
  Future<OrderReceipt> submitOrder(PlaceOrderRequest request) async {
    return OrderReceipt(
      orderId: 'NOVA-026001',
      total: request.total,
      deliveryEta: request.delivery.eta,
    );
  }
}
