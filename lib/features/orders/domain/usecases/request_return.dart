import 'package:fashion_e_commerce/features/orders/domain/entities/return_request.dart';
import 'package:fashion_e_commerce/features/orders/domain/repositories/orders_repository.dart';

class RequestReturn {
  const RequestReturn(this._repository);

  final OrdersRepository _repository;

  Future<ReturnRequest> call(ReturnRequest request) {
    return _repository.submitReturnRequest(request);
  }
}
