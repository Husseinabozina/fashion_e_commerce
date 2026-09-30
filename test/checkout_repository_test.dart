import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/checkout/data/datasources/demo_checkout_data_source.dart';
import 'package:fashion_e_commerce/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/place_order_request.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/shipping_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('checkout returns options and calculates receipt total', () async {
    final repository = CheckoutRepositoryImpl(DemoCheckoutDataSource());
    final options = await repository.getOptions();

    expect(options.deliveryOptions, isNotEmpty);
    expect(options.paymentOptions, isNotEmpty);

    const product = Product(
      id: 'shoe-1',
      brand: 'NOVA',
      name: 'Runner',
      price: 1000,
      imageUrl: '',
      colors: <String>['Black'],
      sizes: <String>['42'],
      fit: 'Regular',
      description: 'Test product',
    );
    const item = CartItem(
      product: product,
      color: 'Black',
      size: '42',
      quantity: 2,
    );
    const address = ShippingAddress(
      fullName: 'Test User',
      phone: '01000000000',
      city: 'Damietta',
      area: 'Centre',
      street: 'Main Street',
      building: '12',
    );

    final express = options.deliveryOptions.last;
    final receipt = await repository.placeOrder(
      PlaceOrderRequest(
        items: const <CartItem>[item],
        address: address,
        delivery: express,
        payment: options.paymentOptions.first,
      ),
    );

    expect(receipt.orderId, 'NOVA-026001');
    expect(receipt.total, 2090);
  });
}
