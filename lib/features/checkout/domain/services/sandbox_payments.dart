import '../entities/place_order_request.dart';
import '../entities/sandbox_payment.dart';

abstract interface class SandboxPayments {
  Future<SandboxPaymentSession> begin(PlaceOrderRequest request);
  Future<SandboxPaymentStatus> check(SandboxPaymentSession session);
  Future<void> forget(SandboxPaymentSession session);
}
