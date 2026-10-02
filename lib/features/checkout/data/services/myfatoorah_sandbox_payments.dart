import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/place_order_request.dart';
import '../../domain/entities/sandbox_payment.dart';
import '../../domain/services/sandbox_payments.dart';
import '../datasources/sandbox_session_store.dart';

/// Uses only MyFatoorah's PUBLIC test credential. Private merchant credentials
/// require a server integration and must never be passed to this class.
class MyFatoorahSandboxPayments implements SandboxPayments {
  MyFatoorahSandboxPayments(this._store,
      {Dio? dio, String? Function()? ownerId})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              followRedirects: false,
            )),
        _ownerId = ownerId ?? (() => null);

  static const _host = 'https://apitest.myfatoorah.com';
  static const _publicTestToken =
      'SK_KWT_vVZlnnAqu8jRByOWaRPNId4ShzEDNt256dvnjebuyzo52dXjAfRx2ixW5umjWSUx';
  final Dio _dio;
  final SandboxSessionStore _store;
  final String? Function() _ownerId;
  final _inFlight = <String, Future<SandboxPaymentSession>>{};
  final _unsaved = <String, SandboxPaymentSession>{};

  void _assertOwner(String? owner) {
    if (_ownerId() != owner) {
      throw StateError('Account changed during payment.');
    }
  }

  static bool isSandboxUrl(Uri url) =>
      url.scheme == 'https' &&
      url.host.toLowerCase() == 'demo.myfatoorah.com' &&
      url.userInfo.isEmpty &&
      (!url.hasPort || url.port == 443);

  Future<Map<String, dynamic>> _post(
      String endpoint, Map<String, dynamic> body) async {
    final response = await _dio.post<dynamic>(
      '$_host/v2/$endpoint',
      data: body,
      options: Options(followRedirects: false, headers: {
        'Authorization': 'Bearer $_publicTestToken',
        'Content-Type': 'application/json',
      }),
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    if (data['IsSuccess'] != true || data['Data'] is! Map) {
      throw StateError('Sandbox provider rejected the request.');
    }
    return Map<String, dynamic>.from(data['Data'] as Map);
  }

  @override
  Future<SandboxPaymentSession> begin(PlaceOrderRequest request) async {
    if (request.items.isEmpty ||
        !request.total.isFinite ||
        request.total <= 0) {
      throw StateError('Invalid sandbox order.');
    }
    final owner = _ownerId();
    final items = request.items
        .map((i) => '${i.key}:${i.quantity}:${i.product.price}')
        .toList()
      ..sort();
    final key = sha256
        .convert(utf8.encode(jsonEncode([
          owner,
          items,
          request.total,
          request.delivery.id,
          request.promotion?.code,
        ])))
        .toString();
    final cacheKey = '${owner ?? 'demo'}:$key';
    final active = _inFlight[cacheKey];
    if (active != null) return active;
    final future = _begin(request, owner, key, cacheKey);
    _inFlight[cacheKey] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(cacheKey);
    }
  }

  Future<SandboxPaymentSession> _begin(PlaceOrderRequest request, String? owner,
      String key, String cacheKey) async {
    final existing = await _store.read(key, owner);
    _assertOwner(owner);
    if (existing != null) {
      if (!isSandboxUrl(existing.checkoutUrl) ||
          existing.orderTotalEgp != request.total) {
        throw StateError('Invalid saved sandbox session.');
      }
      return existing;
    }
    final unsaved = _unsaved[cacheKey];
    if (unsaved != null) {
      await _store.save(unsaved);
      _assertOwner(owner);
      _unsaved.remove(cacheKey);
      return unsaved;
    }
    final methods = await _post('InitiatePayment', {
      'InvoiceAmount': SandboxPaymentSession.testAmount,
      'CurrencyIso': 'KWD',
    });
    _assertOwner(owner);
    final cards = (methods['PaymentMethods'] as List).where((m) =>
        m['PaymentMethodEn'] == 'VISA/MASTER' && m['IsDirectPayment'] != true);
    if (cards.isEmpty) throw StateError('Sandbox cards are unavailable.');
    final random = Random.secure();
    final reference =
        'NOVA-${List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
    final invoice = await _post('ExecutePayment', {
      'PaymentMethodId': cards.first['PaymentMethodId'],
      'InvoiceValue': SandboxPaymentSession.testAmount,
      'DisplayCurrencyIso': 'KWD',
      'CustomerName': 'NOVA Demo', 'Language': 'AR',
      'CustomerReference': reference,
      // No customer PII, card fields, callbacks or messages to real recipients.
    });
    _assertOwner(owner);
    final id = invoice['InvoiceId'];
    final url = Uri.parse(invoice['PaymentURL'] as String);
    if (id is! int ||
        id <= 0 ||
        invoice['IsDirectPayment'] == true ||
        !isSandboxUrl(url) ||
        invoice['CustomerReference'] != reference) {
      throw StateError('Invalid sandbox invoice.');
    }
    final session = SandboxPaymentSession(
        attemptKey: key,
        reference: reference,
        invoiceId: id,
        checkoutUrl: url,
        orderTotalEgp: request.total,
        ownerId: owner);
    _unsaved[cacheKey] = session;
    await _store.save(session);
    _assertOwner(owner);
    _unsaved.remove(cacheKey);
    return session;
  }

  @override
  Future<SandboxPaymentStatus> check(SandboxPaymentSession session) async {
    _assertOwner(session.ownerId);
    final data = await _post('GetPaymentStatus', {
      'Key': session.invoiceId.toString(),
      'KeyType': 'InvoiceId',
    });
    _assertOwner(session.ownerId);
    final display = data['InvoiceDisplayValue']?.toString() ?? '';
    if (data['InvoiceId'] != session.invoiceId ||
        data['CustomerReference'] != session.reference ||
        data['InvoiceValue'] is! num ||
        (data['InvoiceValue'] as num).toDouble() !=
            SandboxPaymentSession.testAmount ||
        !RegExp(r'^1(?:\.0+)?\s+(?:KD|KWD)$').hasMatch(display.trim())) {
      throw StateError('Sandbox receipt does not match this order.');
    }
    if (data['InvoiceStatus'] == 'Paid') return SandboxPaymentStatus.paid;
    if (data['InvoiceStatus'] == 'Canceled' ||
        data['InvoiceStatus'] == 'Cancelled') {
      return SandboxPaymentStatus.cancelled;
    }
    if (data['InvoiceStatus'] != 'Pending') {
      throw StateError('Unrecognized sandbox payment state.');
    }
    final transactions = data['InvoiceTransactions'] as List? ?? [];
    return transactions.isNotEmpty &&
            transactions.last['TransactionStatus'] == 'Failed'
        ? SandboxPaymentStatus.declined
        : SandboxPaymentStatus.pending;
  }

  @override
  Future<void> forget(SandboxPaymentSession session) async {
    _assertOwner(session.ownerId);
    await _store.remove(session);
    _unsaved.remove('${session.ownerId ?? 'demo'}:${session.attemptKey}');
  }
}
