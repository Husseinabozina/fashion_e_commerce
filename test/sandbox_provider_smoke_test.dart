import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fashion_e_commerce/features/checkout/data/datasources/sandbox_session_store.dart';
import 'package:fashion_e_commerce/features/checkout/data/services/myfatoorah_sandbox_payments.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/sandbox_payment.dart';
import 'sandbox_payments_test.dart' show request;

void main() {
  test(
      'live sandbox provider creates a virtual invoice or verifies paid receipt',
      () async {
    final payments = MyFatoorahSandboxPayments(MemorySandboxSessionStore());
    final file = File('build/generated-nova-sandbox-smoke.json');
    if (const bool.fromEnvironment('VERIFY_SANDBOX_PAYMENT')) {
      final d = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final session = SandboxPaymentSession(
          attemptKey: d['attemptKey'] as String,
          reference: d['reference'] as String,
          invoiceId: d['invoiceId'] as int,
          checkoutUrl: Uri.parse(d['checkoutUrl'] as String),
          orderTotalEgp: (d['orderTotalEgp'] as num).toDouble());
      expect(await payments.check(session), SandboxPaymentStatus.paid);
    } else {
      final session = await payments.begin(await request());
      expect(await payments.check(session), SandboxPaymentStatus.pending);
      await file.writeAsString(jsonEncode({
        'attemptKey': session.attemptKey,
        'reference': session.reference,
        'invoiceId': session.invoiceId,
        'checkoutUrl': session.checkoutUrl.toString(),
        'orderTotalEgp': session.orderTotalEgp,
      }));
    }
  },
      skip: !const bool.fromEnvironment('LIVE_SANDBOX_TEST'),
      timeout: const Timeout(Duration(seconds: 90)));
}
