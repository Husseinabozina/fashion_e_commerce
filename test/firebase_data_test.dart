import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashion_e_commerce/features/auth/domain/entities/auth_exception.dart';
import 'dart:convert';
import 'dart:io';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/data/datasources/firestore_catalog_data_source.dart';
import 'package:fashion_e_commerce/features/cart/data/datasources/firestore_cart_data_source.dart';
import 'package:fashion_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:fashion_e_commerce/features/wishlist/data/datasources/firestore_wishlist_data_source.dart';
import 'package:fashion_e_commerce/features/addresses/data/datasources/firestore_addresses_data_source.dart';
import 'package:fashion_e_commerce/features/addresses/domain/entities/saved_address.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/shipping_address.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/place_order_request.dart';
import 'package:fashion_e_commerce/features/checkout/data/datasources/firebase_checkout_data_source.dart';
import 'package:fashion_e_commerce/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:fashion_e_commerce/features/checkout/domain/usecases/place_order.dart';
import 'package:fashion_e_commerce/features/orders/data/datasources/firestore_orders_data_source.dart';
import 'package:fashion_e_commerce/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order.dart';
import 'package:fashion_e_commerce/features/orders/domain/entities/order_status.dart';
import 'package:fashion_e_commerce/features/promotions/data/datasources/firestore_promotions_data_source.dart';
import 'package:fashion_e_commerce/features/notifications/data/datasources/firestore_notifications_data_source.dart';
import 'package:fashion_e_commerce/features/notifications/domain/entities/back_in_stock_subscription.dart';
import 'package:fashion_e_commerce/features/reviews/data/datasources/firestore_reviews_data_source.dart';
import 'package:fashion_e_commerce/features/reviews/domain/entities/product_review.dart';

const address = ShippingAddress(
    fullName: 'Test User',
    phone: '01012345678',
    city: 'Cairo',
    area: 'Nasr City',
    street: 'Main',
    building: '1');
void main() {
  late FakeFirebaseFirestore db;
  late MockFirebaseAuth auth;
  late FirebaseAccountStore store;
  setUp(() async {
    db = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
            uid: 'alice',
            displayName: 'Test User',
            email: 'alice@example.com'));
    store = FirebaseAccountStore(db, auth);
    final docs =
        jsonDecode(File('tools/firebase/catalog-seed.json').readAsStringSync())
            as Map<String, dynamic>;
    for (final entry in docs.entries)
      await db.doc(entry.key).set(Map<String, dynamic>.from(entry.value));
  });
  test(
      'cart and wishlist survive new adapters; account changes reveal only its documents',
      () async {
    final p = (await FirestoreCatalogDataSource(db).fetchProducts()).first;
    final cart = FirestoreCartDataSource(store);
    final wishlist = FirestoreWishlistDataSource(store);
    final item =
        CartItem(product: p, color: p.colors.first, size: p.sizes.first);
    await cart.add(item);
    await cart.add(item);
    await wishlist.toggle(p);
    expect((await FirestoreCartDataSource(store).read()).single.quantity, 2);
    expect((await FirestoreWishlistDataSource(store).read()).single.id, p.id);
    auth.mockUser = MockUser(uid: 'bob');
    expect(await cart.read(), isEmpty);
    expect(await wishlist.read(), isEmpty);
    await cart.clear();
    auth.mockUser = MockUser(uid: 'alice');
    expect((await cart.read()).single.quantity, 2);
    await cart.updateQuantity(item.key, 0);
    expect(await cart.read(), isEmpty);
  });
  test(
      'default address persists, switches once, and removal has a safe fallback',
      () async {
    final source = FirestoreAddressesDataSource(store);
    await source
        .save(const SavedAddress(id: 'home', label: 'Home', address: address));
    await source
        .save(const SavedAddress(id: 'work', label: 'Work', address: address));
    await source.setDefault('work');
    expect(
        (await FirestoreAddressesDataSource(store).readAll())
            .where((a) => a.isDefault)
            .single
            .id,
        'work');
    await source.remove('work');
    expect((await source.readDefault())!.id, 'home');
    auth.mockUser = MockUser(uid: 'bob');
    expect(await source.readDefault(), isNull);
  });
  test(
      'promotion selection persists with account scope and subtotal validation',
      () async {
    final source = FirestorePromotionsDataSource(store);
    await source.apply(code: ' street10 ', subtotal: 2000);
    expect((await FirestorePromotionsDataSource(store).readApplied())!.code,
        'STREET10');
    await expectLater(
        source.apply(code: 'NOVA500', subtotal: 2000), throwsStateError);
    auth.mockUser = MockUser(uid: 'bob');
    expect(await source.readApplied(), isNull);
  });
  test(
      'retried checkout stores one receipt and preserves immutable product snapshots',
      () async {
    final product =
        (await FirestoreCatalogDataSource(db).fetchProducts()).first;
    final checkout = FirebaseCheckoutDataSource(store);
    final options = await checkout.fetchOptions();
    final place = PlaceOrder(CheckoutRepositoryImpl(checkout),
        OrdersRepositoryImpl(FirestoreOrdersDataSource(store)));
    final request = PlaceOrderRequest(
        items: [
          CartItem(
              product: product,
              color: product.colors.first,
              size: product.sizes.first)
        ],
        address: address,
        delivery: options.deliveryOptions.first,
        payment: options.paymentOptions.first,
        idempotencyKey: 'stable-attempt');
    final a = await place(request);
    final b = await place(request);
    expect(a.orderId, b.orderId);
    expect(a.ownerId, 'alice');
    final orders = FirestoreOrdersDataSource(store);
    expect(await orders.readAll(), hasLength(1));
    await db
        .collection('products')
        .doc(product.id)
        .update({'price': 1, 'name': 'Changed'});
    final receipt = await orders.readById(a.orderId);
    expect(receipt.items.single.product.price, product.price);
    expect(receipt.items.single.product.name, product.name);
    expect(receipt.total, a.total);
    auth.mockUser = MockUser(uid: 'bob');
    expect(await orders.readAll(), isEmpty);
  });
  test('account transition rejects order persistence under another owner',
      () async {
    final product =
        (await FirestoreCatalogDataSource(db).fetchProducts()).first;
    final order = Order(
        id: 'NOVA-inflight',
        ownerId: 'alice',
        items: [CartItem(product: product, color: 'Black', size: '42')],
        total: 3499,
        createdAt: DateTime.now(),
        deliveryEta: '3 days',
        shippingAddressLabel: 'Cairo',
        deliveryTitle: 'Standard Delivery',
        paymentTitle: 'Card',
        status: OrderStatus.placed);
    auth.mockUser = MockUser(uid: 'bob');
    await expectLater(
        FirestoreOrdersDataSource(store).save(order), throwsStateError);
    expect(await store.collection('demoOrders').get(),
        predicate((dynamic snapshot) => snapshot.docs.isEmpty));
  });
  test('subscriptions deduplicate across launches and never cross accounts',
      () async {
    const subscription = BackInStockSubscription(
        productId: 'nb-9060', color: 'Black', size: '44');
    final source = FirestoreNotificationsDataSource(store);
    expect(await source.subscribe(subscription), isTrue);
    expect(
        await FirestoreNotificationsDataSource(store).subscribe(subscription),
        isFalse);
    auth.mockUser = MockUser(uid: 'bob');
    expect(await source.containsSubscription(subscription), isFalse);
  });
  test(
      'reviews use authenticated author; edits retain creation date and one review',
      () async {
    final source = FirestoreReviewsDataSource(store);
    final review = ProductReview(
        id: 'ignored',
        productId: 'nb-9060',
        authorName: 'Spoofed',
        rating: 4,
        comment: 'Good',
        fit: FitFeedback.trueToSize,
        createdAt: DateTime(2000));
    final first = await source.add(review);
    final second = await source.add(review);
    expect(first.authorName, 'Test User');
    expect(first.id, 'alice');
    expect(second.createdAt, first.createdAt);
    expect(await source.read('nb-9060'), hasLength(1));
    expect(second.verifiedPurchase, isFalse);
    auth.mockUser = MockUser(uid: 'guest', isAnonymous: true);
    await expectLater(source.add(review), throwsStateError);
  });
  test(
      'failed credentials preserve the guest and never fall back to registration',
      () async {
    final failingAuth = _RejectingAuth();
    await expectLater(
        FirebaseAuthDataSource(failingAuth)
            .signIn(email: 'missing@example.com', password: 'incorrect'),
        throwsA(isA<AuthException>()
            .having((e) => e.code, 'code', 'invalid-credential')));
    expect(failingAuth.currentUser!.uid, 'guest-existing');
    expect(failingAuth.registrations, 0);
  });
  test('restoring a guest session keeps its Firebase UID', () async {
    auth.mockUser = MockUser(uid: 'guest-existing', isAnonymous: true);
    final user = await FirebaseAuthDataSource(auth).currentUser();
    expect(user.id, 'guest-existing');
    expect(user.isGuest, isTrue);
  });
}

class _RejectingAuth extends MockFirebaseAuth {
  _RejectingAuth()
      : super(
            signedIn: true,
            mockUser: MockUser(uid: 'guest-existing', isAnonymous: true));
  int registrations = 0;
  @override
  Future<UserCredential> signInWithEmailAndPassword(
          {required String email, required String password}) async =>
      throw FirebaseAuthException(code: 'invalid-credential');
  @override
  Future<UserCredential> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    registrations++;
    return super
        .createUserWithEmailAndPassword(email: email, password: password);
  }
}
