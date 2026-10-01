import 'package:fashion_e_commerce/features/orders/domain/entities/order.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/return_request.dart';
import 'package:fashion_e_commerce/features/orders/domain/usecases/get_order_details.dart';
import 'package:fashion_e_commerce/features/orders/domain/usecases/request_return.dart';
import 'package:fashion_e_commerce/core/presentation/account_cubit.dart';

sealed class OrderDetailsState {
  const OrderDetailsState();
}

final class OrderDetailsLoading extends OrderDetailsState {
  const OrderDetailsLoading();
}

final class OrderDetailsReady extends OrderDetailsState {
  const OrderDetailsReady({
    required this.order,
    this.submittedRequest,
  });

  final Order order;
  final ReturnRequest? submittedRequest;
}

final class OrderDetailsFailure extends OrderDetailsState {
  const OrderDetailsFailure(this.message);

  final String message;
}

class OrderDetailsCubit extends AccountCubit<OrderDetailsState> {
  OrderDetailsCubit(
    this._getOrderDetails,
    this._requestReturn,
  ) : super(const OrderDetailsLoading());

  final GetOrderDetails _getOrderDetails;
  final RequestReturn _requestReturn;
  String? _orderId;

  Future<void> load(String orderId) async {
    _orderId = orderId;
    emit(const OrderDetailsLoading());

    try {
      emit(OrderDetailsReady(order: await _getOrderDetails(orderId)));
    } catch (_) {
      emit(const OrderDetailsFailure('Order could not be loaded.'));
    }
  }

  Future<void> submitReturn({
    required String itemKey,
    required ReturnRequestType type,
    required String reason,
    String? requestedSize,
  }) async {
    final orderId = _orderId;
    if (orderId == null) return;

    final request = await _requestReturn(
      ReturnRequest(
        id: 'RET-${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        itemKey: itemKey,
        type: type,
        reason: reason,
        requestedSize: requestedSize,
        status: ReturnRequestStatus.submitted,
      ),
    );

    emit(
      OrderDetailsReady(
        order: await _getOrderDetails(orderId),
        submittedRequest: request,
      ),
    );
  }
}
