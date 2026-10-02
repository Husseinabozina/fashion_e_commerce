import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/checkout/data/datasources/demo_checkout_data_source.dart';
import 'package:fashion_e_commerce/features/checkout/data/datasources/sandbox_session_store.dart';
import 'package:fashion_e_commerce/features/checkout/data/services/myfatoorah_sandbox_payments.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/place_order_request.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/sandbox_payment.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/shipping_address.dart';

Future<PlaceOrderRequest> request() async {
  final options = await DemoCheckoutDataSource().fetchOptions();
  return PlaceOrderRequest(
    items: const [
      CartItem(
          product: Product(
              id: 'p1',
              brand: 'NOVA',
              name: 'Test',
              category: 'Sneakers',
              price: 1000,
              imageUrl: '',
              colors: ['Black'],
              sizes: ['42'],
              fit: 'Regular',
              description: 'Test'),
          color: 'Black',
          size: '42')
    ],
    address: const ShippingAddress(
        fullName: 'Private Shopper',
        phone: '01012345678',
        city: 'Cairo',
        area: 'Centre',
        street: 'Private Street',
        building: '12'),
    delivery: options.deliveryOptions.first,
    payment: options.paymentOptions.first,
  );
}

class ProviderAdapter implements HttpClientAdapter {
  int creates = 0;
  String? reference;
  String status = 'Pending';
  String url =
      'https://demo.myfatoorah.com/Ar/KWT/PayInvoice/Checkout?invoiceKey=test';
  Map<String, dynamic> receiptPatch = {};
  bool offline = false;
  final bodies = <Map<String, dynamic>>[];
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    expect(options.uri.host, 'apitest.myfatoorah.com');
    expect(options.followRedirects, isFalse);
    final body = Map<String, dynamic>.from(options.data as Map);
    bodies.add(body);
    if (offline) {
      throw DioException(
          requestOptions: options, type: DioExceptionType.connectionError);
    }
    final Map<String, dynamic> result;
    if (options.path.endsWith('InitiatePayment')) {
      result = {
        'PaymentMethods': [
          {'PaymentMethodEn': 'KNET', 'PaymentMethodId': 1},
          {
            'PaymentMethodEn': 'VISA/MASTER',
            'PaymentMethodId': 2,
            'IsDirectPayment': false
          },
        ]
      };
    } else if (options.path.endsWith('ExecutePayment')) {
      creates++;
      reference = body['CustomerReference'] as String;
      result = {
        'InvoiceId': 123,
        'CustomerReference': reference,
        'PaymentURL': url,
        'IsDirectPayment': false
      };
    } else {
      result = {
        'InvoiceId': 123,
        'CustomerReference': reference,
        'InvoiceValue': 1,
        'InvoiceDisplayValue': '1.000 KD',
        'InvoiceStatus': status,
        'InvoiceTransactions': [],
        ...receiptPatch
      };
    }
    return ResponseBody.fromString(
        jsonEncode({'IsSuccess': true, 'Data': result}), 200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late ProviderAdapter api;
  late MemorySandboxSessionStore store;
  late MyFatoorahSandboxPayments payments;
  setUp(() {
    api = ProviderAdapter();
    store = MemorySandboxSessionStore();
    payments =
        MyFatoorahSandboxPayments(store, dio: Dio()..httpClientAdapter = api);
  });
  test('concurrent/repeated attempts reuse invoice and send no customer PII',
      () async {
    final order = await request();
    final sessions =
        await Future.wait([payments.begin(order), payments.begin(order)]);
    expect(sessions[0].invoiceId, sessions[1].invoiceId);
    await payments.begin(order);
    expect(api.creates, 1);
    final body = api.bodies.firstWhere((b) => b.containsKey('InvoiceValue'));
    expect(body['InvoiceValue'], 1);
    expect(body['DisplayCurrencyIso'], 'KWD');
    expect(body['CustomerName'], 'NOVA Demo');
    expect(body.keys, isNot(contains('CustomerEmail')));
    expect(body.keys, isNot(contains('CustomerAddress')));
    expect(body.keys, isNot(contains('CustomerMobile')));
  });
  test('new adapter restores pending invoice without creating another',
      () async {
    final session = await payments.begin(await request());
    final restarted =
        MyFatoorahSandboxPayments(store, dio: Dio()..httpClientAdapter = api);
    expect(
        (await restarted.begin(await request())).invoiceId, session.invoiceId);
    expect(api.creates, 1);
  });
  test(
      'only matching paid invoice is accepted; failed and pending stay incomplete',
      () async {
    final session = await payments.begin(await request());
    expect(await payments.check(session), SandboxPaymentStatus.pending);
    api.receiptPatch = {
      'InvoiceTransactions': [
        {'TransactionStatus': 'Failed'}
      ]
    };
    expect(await payments.check(session), SandboxPaymentStatus.declined);
    api.status = 'Paid';
    expect(await payments.check(session), SandboxPaymentStatus.paid);
  });
  test('receipt identity, amount, currency and unknown state fail closed',
      () async {
    final session = await payments.begin(await request());
    api.status = 'Paid';
    for (final patch in [
      {'InvoiceId': 999},
      {'CustomerReference': 'someone-else'},
      {'InvoiceValue': 1000},
      {'InvoiceDisplayValue': '1.000 USD'},
      {'InvoiceStatus': 'Unknown'},
    ]) {
      api.receiptPatch = patch;
      await expectLater(payments.check(session), throwsStateError);
    }
  });
  test('live and lookalike hosted URLs are refused', () async {
    for (final url in [
      'https://portal.myfatoorah.com/pay',
      'https://demo.myfatoorah.com.evil.test/pay',
      'http://demo.myfatoorah.com/pay'
    ]) {
      api.url = url;
      await expectLater(payments.begin(await request()), throwsStateError);
    }
  });
  test('network failure never returns a paid result', () async {
    final session = await payments.begin(await request());
    api.offline = true;
    await expectLater(payments.check(session), throwsA(isA<DioException>()));
  });
  test('failed persistence retries save of the same invoice', () async {
    final failing = _FailOnceStore();
    final service =
        MyFatoorahSandboxPayments(failing, dio: Dio()..httpClientAdapter = api);
    await expectLater(service.begin(await request()), throwsStateError);
    await service.begin(await request());
    expect(api.creates, 1);
  });
  test('private Firestore sessions survive restart and cannot cross accounts',
      () async {
    final db = FakeFirebaseFirestore();
    final auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'alice'));
    final account = FirebaseAccountStore(db, auth);
    final service = MyFatoorahSandboxPayments(
        FirestoreSandboxSessionStore(account),
        dio: Dio()..httpClientAdapter = api,
        ownerId: () => account.uid);
    final session = await service.begin(await request());
    final restored = await FirestoreSandboxSessionStore(account)
        .read(session.attemptKey, 'alice');
    expect(restored!.invoiceId, session.invoiceId);
    auth.mockUser = MockUser(uid: 'bob');
    await expectLater(service.check(session), throwsStateError);
    await expectLater(FirestoreSandboxSessionStore(account).remove(session),
        throwsStateError);
    expect((await db.collection('users/alice/sandboxPayments').get()).docs,
        hasLength(1));
  });
  test('completed invoice is consumed after a failed pointer cleanup',
      () async {
    final db = FakeFirebaseFirestore();
    final auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'alice'));
    final account = FirebaseAccountStore(db, auth);
    final saved = FirestoreSandboxSessionStore(account);
    final service = MyFatoorahSandboxPayments(saved,
        dio: Dio()..httpClientAdapter = api, ownerId: () => account.uid);
    final session = await service.begin(await request());
    await db
        .doc('users/alice/demoOrders/NOVA-TEST-${session.invoiceId}')
        .set({'isDemo': true});
    expect(await saved.read(session.attemptKey, 'alice'), isNull);
    await service.begin(await request());
    expect(api.creates, 2);
  });
}

class _FailOnceStore extends MemorySandboxSessionStore {
  bool fail = true;
  @override
  Future<void> save(SandboxPaymentSession session) async {
    if (fail) {
      fail = false;
      throw StateError('offline storage');
    }
    await super.save(session);
  }
}
