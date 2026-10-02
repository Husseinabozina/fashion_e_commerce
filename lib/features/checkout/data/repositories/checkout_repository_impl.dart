import 'package:fashion_e_commerce/features/checkout/data/datasources/checkout_data_source.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/checkout_options.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/order_receipt.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/place_order_request.dart';
import 'package:fashion_e_commerce/features/checkout/domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  const CheckoutRepositoryImpl(this._dataSource);

  final CheckoutDataSource _dataSource;

  @override
  Future<CheckoutOptions> getOptions() => _dataSource.fetchOptions();

  @override
  Future<OrderReceipt> placeOrder(PlaceOrderRequest request) {
    return _dataSource.submitOrder(request);
  }
}
