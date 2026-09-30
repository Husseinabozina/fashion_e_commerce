import 'package:fashion_e_commerce/features/orders/domain/entities/order.dart';
import 'package:fashion_e_commerce/features/orders/domain/usecases/get_orders.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class OrdersState {
  const OrdersState();
}

final class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

final class OrdersLoaded extends OrdersState {
  const OrdersLoaded(this.orders);

  final List<Order> orders;
}

final class OrdersFailure extends OrdersState {
  const OrdersFailure(this.message);

  final String message;
}

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._getOrders) : super(const OrdersLoading());

  final GetOrders _getOrders;

  Future<void> load() async {
    emit(const OrdersLoading());

    try {
      emit(OrdersLoaded(await _getOrders()));
    } catch (_) {
      emit(const OrdersFailure('Orders could not be loaded.'));
    }
  }
}
