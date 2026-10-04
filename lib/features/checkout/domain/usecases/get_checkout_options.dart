import 'package:fashion_e_commerce/features/checkout/domain/entities/checkout_options.dart';
import 'package:fashion_e_commerce/features/checkout/domain/repositories/checkout_repository.dart';

class GetCheckoutOptions {
  const GetCheckoutOptions(this._repository);

  final CheckoutRepository _repository;

  Future<CheckoutOptions> call() => _repository.getOptions();
}
