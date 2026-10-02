import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fashion_e_commerce/features/notifications/data/datasources/firebase_push_notifications.dart';
import 'package:fashion_e_commerce/features/notifications/domain/services/push_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashion_e_commerce/core/firebase/firebase_account_store.dart';
import 'package:fashion_e_commerce/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/create_account.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/reset_password.dart';
import 'package:fashion_e_commerce/features/addresses/data/datasources/firestore_addresses_data_source.dart';
import 'package:fashion_e_commerce/features/brands/data/datasources/firestore_brands_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/data/datasources/firestore_catalog_data_source.dart';
import 'package:fashion_e_commerce/features/cart/data/datasources/firestore_cart_data_source.dart';
import 'package:fashion_e_commerce/features/notifications/data/datasources/firestore_notifications_data_source.dart';
import 'package:fashion_e_commerce/features/onboarding/data/datasources/firestore_preferences_data_source.dart';
import 'package:fashion_e_commerce/features/orders/data/datasources/firestore_orders_data_source.dart';
import 'package:fashion_e_commerce/features/promotions/data/datasources/firestore_promotions_data_source.dart';
import 'package:fashion_e_commerce/features/recently_viewed/data/datasources/firestore_recently_viewed_data_source.dart';
import 'package:fashion_e_commerce/features/reviews/data/datasources/firestore_reviews_data_source.dart';
import 'package:fashion_e_commerce/features/wishlist/data/datasources/firestore_wishlist_data_source.dart';
import 'package:fashion_e_commerce/features/checkout/data/datasources/firebase_checkout_data_source.dart';
import 'package:fashion_e_commerce/core/localization/locale_cubit.dart';
import 'package:fashion_e_commerce/features/addresses/data/datasources/addresses_data_source.dart';
import 'package:fashion_e_commerce/features/addresses/data/datasources/in_memory_addresses_data_source.dart';
import 'package:fashion_e_commerce/features/addresses/data/repositories/addresses_repository_impl.dart';
import 'package:fashion_e_commerce/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:fashion_e_commerce/features/addresses/domain/usecases/get_addresses.dart';
import 'package:fashion_e_commerce/features/addresses/domain/usecases/get_default_address.dart';
import 'package:fashion_e_commerce/features/addresses/domain/usecases/remove_address.dart';
import 'package:fashion_e_commerce/features/addresses/domain/usecases/save_address.dart';
import 'package:fashion_e_commerce/features/addresses/domain/usecases/set_default_address.dart';
import 'package:fashion_e_commerce/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:fashion_e_commerce/features/auth/data/datasources/auth_data_source.dart';
import 'package:fashion_e_commerce/features/auth/data/datasources/in_memory_auth_data_source.dart';
import 'package:fashion_e_commerce/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fashion_e_commerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/get_current_user.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/sign_in.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/sign_out.dart';
import 'package:fashion_e_commerce/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fashion_e_commerce/features/brands/data/datasources/brands_data_source.dart';
import 'package:fashion_e_commerce/features/brands/data/datasources/in_memory_brands_data_source.dart';
import 'package:fashion_e_commerce/features/brands/data/repositories/brands_repository_impl.dart';
import 'package:fashion_e_commerce/features/brands/domain/repositories/brands_repository.dart';
import 'package:fashion_e_commerce/features/brands/domain/usecases/get_brand.dart';
import 'package:fashion_e_commerce/features/brands/domain/usecases/get_following_brands.dart';
import 'package:fashion_e_commerce/features/brands/domain/usecases/is_following_brand.dart';
import 'package:fashion_e_commerce/features/brands/domain/usecases/toggle_brand_follow.dart';
import 'package:fashion_e_commerce/features/brands/presentation/cubit/brand_cubit.dart';
import 'package:fashion_e_commerce/features/brands/presentation/cubit/following_brands_cubit.dart';
import 'package:fashion_e_commerce/features/cart/data/datasources/cart_data_source.dart';
import 'package:fashion_e_commerce/features/cart/data/datasources/in_memory_cart_data_source.dart';
import 'package:fashion_e_commerce/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:fashion_e_commerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/add_to_cart.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/change_cart_quantity.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/clear_cart.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/get_cart.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/remove_cart_item.dart';
import 'package:fashion_e_commerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:fashion_e_commerce/features/checkout/data/datasources/checkout_data_source.dart';
import 'package:fashion_e_commerce/features/checkout/data/datasources/demo_checkout_data_source.dart';
import 'package:fashion_e_commerce/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:fashion_e_commerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:fashion_e_commerce/features/checkout/domain/usecases/get_checkout_options.dart';
import 'package:fashion_e_commerce/features/checkout/domain/usecases/place_order.dart';
import 'package:fashion_e_commerce/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/data/datasources/catalog_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/data/datasources/demo_catalog_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:fashion_e_commerce/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_complete_look.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_home_catalog.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_product_details.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/search_products.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/catalog_browse_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/product_details_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/search_cubit.dart';
import 'package:fashion_e_commerce/features/notifications/data/datasources/in_memory_notifications_data_source.dart';
import 'package:fashion_e_commerce/features/notifications/data/datasources/notifications_data_source.dart';
import 'package:fashion_e_commerce/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:fashion_e_commerce/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:fashion_e_commerce/features/notifications/domain/usecases/get_notifications.dart';
import 'package:fashion_e_commerce/features/notifications/domain/usecases/mark_notifications_read.dart';
import 'package:fashion_e_commerce/features/notifications/domain/usecases/subscribe_back_in_stock.dart';
import 'package:fashion_e_commerce/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:fashion_e_commerce/features/onboarding/data/datasources/in_memory_preferences_data_source.dart';
import 'package:fashion_e_commerce/features/onboarding/data/datasources/preferences_data_source.dart';
import 'package:fashion_e_commerce/features/onboarding/data/repositories/preferences_repository_impl.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/repositories/preferences_repository.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/usecases/get_shopping_preferences.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/usecases/save_shopping_preferences.dart';
import 'package:fashion_e_commerce/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:fashion_e_commerce/features/orders/data/datasources/in_memory_orders_data_source.dart';
import 'package:fashion_e_commerce/features/orders/data/datasources/orders_data_source.dart';
import 'package:fashion_e_commerce/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:fashion_e_commerce/features/orders/domain/repositories/orders_repository.dart';
import 'package:fashion_e_commerce/features/orders/domain/usecases/get_order_details.dart';
import 'package:fashion_e_commerce/features/orders/domain/usecases/get_orders.dart';
import 'package:fashion_e_commerce/features/orders/domain/usecases/request_return.dart';
import 'package:fashion_e_commerce/features/orders/presentation/cubit/order_details_cubit.dart';
import 'package:fashion_e_commerce/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:fashion_e_commerce/features/promotions/data/datasources/in_memory_promotions_data_source.dart';
import 'package:fashion_e_commerce/features/promotions/data/datasources/promotions_data_source.dart';
import 'package:fashion_e_commerce/features/promotions/data/repositories/promotions_repository_impl.dart';
import 'package:fashion_e_commerce/features/promotions/domain/repositories/promotions_repository.dart';
import 'package:fashion_e_commerce/features/promotions/domain/usecases/apply_promotion_code.dart';
import 'package:fashion_e_commerce/features/promotions/domain/usecases/clear_promotion.dart';
import 'package:fashion_e_commerce/features/promotions/domain/usecases/get_applied_promotion.dart';
import 'package:fashion_e_commerce/features/promotions/presentation/cubit/promotions_cubit.dart';
import 'package:fashion_e_commerce/features/recently_viewed/data/datasources/in_memory_recently_viewed_data_source.dart';
import 'package:fashion_e_commerce/features/recently_viewed/data/datasources/recently_viewed_data_source.dart';
import 'package:fashion_e_commerce/features/recently_viewed/data/repositories/recently_viewed_repository_impl.dart';
import 'package:fashion_e_commerce/features/recently_viewed/domain/repositories/recently_viewed_repository.dart';
import 'package:fashion_e_commerce/features/recently_viewed/domain/usecases/get_recently_viewed.dart';
import 'package:fashion_e_commerce/features/recently_viewed/domain/usecases/track_recently_viewed.dart';
import 'package:fashion_e_commerce/features/recently_viewed/presentation/cubit/recently_viewed_cubit.dart';
import 'package:fashion_e_commerce/features/reviews/data/datasources/in_memory_reviews_data_source.dart';
import 'package:fashion_e_commerce/features/reviews/data/datasources/reviews_data_source.dart';
import 'package:fashion_e_commerce/features/reviews/data/repositories/reviews_repository_impl.dart';
import 'package:fashion_e_commerce/features/reviews/domain/repositories/reviews_repository.dart';
import 'package:fashion_e_commerce/features/reviews/domain/usecases/get_product_reviews.dart';
import 'package:fashion_e_commerce/features/reviews/domain/usecases/submit_product_review.dart';
import 'package:fashion_e_commerce/features/wishlist/data/datasources/in_memory_wishlist_data_source.dart';
import 'package:fashion_e_commerce/features/wishlist/data/datasources/wishlist_data_source.dart';
import 'package:fashion_e_commerce/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:fashion_e_commerce/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:fashion_e_commerce/features/wishlist/domain/usecases/get_wishlist.dart';
import 'package:fashion_e_commerce/features/wishlist/domain/usecases/toggle_wishlist.dart';
import 'package:fashion_e_commerce/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:get_it/get_it.dart';

final GetIt serviceLocator = GetIt.instance;

void configureDependencies(
    {FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
    FirebaseMessaging? messaging}) {
  if ((firestore == null) != (firebaseAuth == null))
    throw ArgumentError('Provide both Firebase services.');
  final store =
      firestore != null ? FirebaseAccountStore(firestore, firebaseAuth!) : null;
  if (serviceLocator.isRegistered<HomeCubit>()) return;

  final push = store != null && messaging != null
      ? FirebasePushNotifications(store, messaging)
      : null;
  if (push != null)
    serviceLocator.registerSingleton<PushNotifications>(push,
        dispose: (service) => service.dispose());

  serviceLocator
    ..registerLazySingleton<AddressesDataSource>(
      () => store == null
          ? InMemoryAddressesDataSource()
          : FirestoreAddressesDataSource(store),
    )
    ..registerLazySingleton<AddressesRepository>(
      () => AddressesRepositoryImpl(serviceLocator<AddressesDataSource>()),
    )
    ..registerLazySingleton<GetAddresses>(
      () => GetAddresses(serviceLocator<AddressesRepository>()),
    )
    ..registerLazySingleton<GetDefaultAddress>(
      () => GetDefaultAddress(serviceLocator<AddressesRepository>()),
    )
    ..registerLazySingleton<SaveAddress>(
      () => SaveAddress(serviceLocator<AddressesRepository>()),
    )
    ..registerLazySingleton<RemoveAddress>(
      () => RemoveAddress(serviceLocator<AddressesRepository>()),
    )
    ..registerLazySingleton<SetDefaultAddress>(
      () => SetDefaultAddress(serviceLocator<AddressesRepository>()),
    )
    ..registerLazySingleton<AuthDataSource>(
      () => firebaseAuth == null
          ? InMemoryAuthDataSource()
          : FirebaseAuthDataSource(firebaseAuth,
              beforeAccountChange: push?.beforeAccountChange,
              afterAccountChange: push?.afterAccountChange),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator<AuthDataSource>()),
    )
    ..registerLazySingleton<GetCurrentUser>(
      () => GetCurrentUser(serviceLocator<AuthRepository>()),
    )
    ..registerLazySingleton<CreateAccount>(
        () => CreateAccount(serviceLocator<AuthRepository>()))
    ..registerLazySingleton<ResetPassword>(
        () => ResetPassword(serviceLocator<AuthRepository>()))
    ..registerLazySingleton<SignIn>(
      () => SignIn(serviceLocator<AuthRepository>()),
    )
    ..registerLazySingleton<SignOut>(
      () => SignOut(serviceLocator<AuthRepository>()),
    )
    ..registerLazySingleton<BrandsDataSource>(
      () => store == null
          ? InMemoryBrandsDataSource()
          : FirestoreBrandsDataSource(store),
    )
    ..registerLazySingleton<BrandsRepository>(
      () => BrandsRepositoryImpl(serviceLocator<BrandsDataSource>()),
    )
    ..registerLazySingleton<GetBrand>(
      () => GetBrand(serviceLocator<BrandsRepository>()),
    )
    ..registerLazySingleton<GetFollowingBrands>(
      () => GetFollowingBrands(serviceLocator<BrandsRepository>()),
    )
    ..registerLazySingleton<IsFollowingBrand>(
      () => IsFollowingBrand(serviceLocator<BrandsRepository>()),
    )
    ..registerLazySingleton<ToggleBrandFollow>(
      () => ToggleBrandFollow(serviceLocator<BrandsRepository>()),
    )
    ..registerLazySingleton<PreferencesDataSource>(
      () => store == null
          ? InMemoryPreferencesDataSource()
          : FirestorePreferencesDataSource(store),
    )
    ..registerLazySingleton<PreferencesRepository>(
      () => PreferencesRepositoryImpl(
        serviceLocator<PreferencesDataSource>(),
      ),
    )
    ..registerLazySingleton<GetShoppingPreferences>(
      () => GetShoppingPreferences(
        serviceLocator<PreferencesRepository>(),
      ),
    )
    ..registerLazySingleton<SaveShoppingPreferences>(
      () => SaveShoppingPreferences(
        serviceLocator<PreferencesRepository>(),
      ),
    )
    ..registerLazySingleton<CatalogDataSource>(
      () => store == null
          ? DemoCatalogDataSource()
          : FirestoreCatalogDataSource(firestore!),
    )
    ..registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(serviceLocator<CatalogDataSource>()),
    )
    ..registerLazySingleton<GetHomeCatalog>(
      () => GetHomeCatalog(
        serviceLocator<CatalogRepository>(),
        serviceLocator<PreferencesRepository>(),
      ),
    )
    ..registerLazySingleton<GetCompleteLook>(
      () => GetCompleteLook(serviceLocator<CatalogRepository>()),
    )
    ..registerLazySingleton<GetProductDetails>(
      () => GetProductDetails(serviceLocator<CatalogRepository>()),
    )
    ..registerLazySingleton<SearchProducts>(
      () => SearchProducts(serviceLocator<CatalogRepository>()),
    )
    ..registerLazySingleton<CartDataSource>(
      () => store == null
          ? InMemoryCartDataSource()
          : FirestoreCartDataSource(store),
    )
    ..registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(serviceLocator<CartDataSource>()),
    )
    ..registerLazySingleton<AddToCart>(
      () => AddToCart(serviceLocator<CartRepository>()),
    )
    ..registerLazySingleton<GetCart>(
      () => GetCart(serviceLocator<CartRepository>()),
    )
    ..registerLazySingleton<ChangeCartQuantity>(
      () => ChangeCartQuantity(serviceLocator<CartRepository>()),
    )
    ..registerLazySingleton<RemoveCartItem>(
      () => RemoveCartItem(serviceLocator<CartRepository>()),
    )
    ..registerLazySingleton<ClearCart>(
      () => ClearCart(serviceLocator<CartRepository>()),
    )
    ..registerLazySingleton<PromotionsDataSource>(
      () => store == null
          ? InMemoryPromotionsDataSource()
          : FirestorePromotionsDataSource(store),
    )
    ..registerLazySingleton<PromotionsRepository>(
      () => PromotionsRepositoryImpl(serviceLocator<PromotionsDataSource>()),
    )
    ..registerLazySingleton<GetAppliedPromotion>(
      () => GetAppliedPromotion(serviceLocator<PromotionsRepository>()),
    )
    ..registerLazySingleton<ApplyPromotionCode>(
      () => ApplyPromotionCode(serviceLocator<PromotionsRepository>()),
    )
    ..registerLazySingleton<ClearPromotion>(
      () => ClearPromotion(serviceLocator<PromotionsRepository>()),
    )
    ..registerLazySingleton<RecentlyViewedDataSource>(
      () => store == null
          ? InMemoryRecentlyViewedDataSource()
          : FirestoreRecentlyViewedDataSource(store),
    )
    ..registerLazySingleton<RecentlyViewedRepository>(
      () => RecentlyViewedRepositoryImpl(
        serviceLocator<RecentlyViewedDataSource>(),
      ),
    )
    ..registerLazySingleton<GetRecentlyViewed>(
      () => GetRecentlyViewed(
        serviceLocator<RecentlyViewedRepository>(),
      ),
    )
    ..registerLazySingleton<TrackRecentlyViewed>(
      () => TrackRecentlyViewed(
        serviceLocator<RecentlyViewedRepository>(),
      ),
    )
    ..registerLazySingleton<ReviewsDataSource>(
      () => store == null
          ? InMemoryReviewsDataSource()
          : FirestoreReviewsDataSource(store),
    )
    ..registerLazySingleton<ReviewsRepository>(
      () => ReviewsRepositoryImpl(serviceLocator<ReviewsDataSource>()),
    )
    ..registerLazySingleton<GetProductReviews>(
      () => GetProductReviews(serviceLocator<ReviewsRepository>()),
    )
    ..registerLazySingleton<SubmitProductReview>(
      () => SubmitProductReview(serviceLocator<ReviewsRepository>()),
    )
    ..registerLazySingleton<WishlistDataSource>(
      () => store == null
          ? InMemoryWishlistDataSource()
          : FirestoreWishlistDataSource(store),
    )
    ..registerLazySingleton<WishlistRepository>(
      () => WishlistRepositoryImpl(serviceLocator<WishlistDataSource>()),
    )
    ..registerLazySingleton<GetWishlist>(
      () => GetWishlist(serviceLocator<WishlistRepository>()),
    )
    ..registerLazySingleton<ToggleWishlist>(
      () => ToggleWishlist(serviceLocator<WishlistRepository>()),
    )
    ..registerLazySingleton<NotificationsDataSource>(
      () => store == null
          ? InMemoryNotificationsDataSource()
          : FirestoreNotificationsDataSource(store),
    )
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(
        serviceLocator<NotificationsDataSource>(),
      ),
    )
    ..registerLazySingleton<GetNotifications>(
      () => GetNotifications(serviceLocator<NotificationsRepository>()),
    )
    ..registerLazySingleton<MarkNotificationsRead>(
      () => MarkNotificationsRead(
        serviceLocator<NotificationsRepository>(),
      ),
    )
    ..registerLazySingleton<SubscribeBackInStock>(
      () => SubscribeBackInStock(
        serviceLocator<NotificationsRepository>(),
      ),
    )
    ..registerLazySingleton<OrdersDataSource>(
      () => store == null
          ? InMemoryOrdersDataSource()
          : FirestoreOrdersDataSource(store),
    )
    ..registerLazySingleton<OrdersRepository>(
      () => OrdersRepositoryImpl(serviceLocator<OrdersDataSource>()),
    )
    ..registerLazySingleton<GetOrders>(
      () => GetOrders(serviceLocator<OrdersRepository>()),
    )
    ..registerLazySingleton<GetOrderDetails>(
      () => GetOrderDetails(serviceLocator<OrdersRepository>()),
    )
    ..registerLazySingleton<RequestReturn>(
      () => RequestReturn(serviceLocator<OrdersRepository>()),
    )
    ..registerLazySingleton<CheckoutDataSource>(
      () => store == null
          ? DemoCheckoutDataSource()
          : FirebaseCheckoutDataSource(store),
    )
    ..registerLazySingleton<CheckoutRepository>(
      () => CheckoutRepositoryImpl(serviceLocator<CheckoutDataSource>()),
    )
    ..registerLazySingleton<GetCheckoutOptions>(
      () => GetCheckoutOptions(serviceLocator<CheckoutRepository>()),
    )
    ..registerLazySingleton<PlaceOrder>(
      () => PlaceOrder(
        serviceLocator<CheckoutRepository>(),
        serviceLocator<OrdersRepository>(),
      ),
    )
    ..registerFactory<LocaleCubit>(LocaleCubit.new)
    ..registerFactory<AddressesCubit>(
      () => AddressesCubit(
        serviceLocator<GetAddresses>(),
        serviceLocator<SaveAddress>(),
        serviceLocator<RemoveAddress>(),
        serviceLocator<SetDefaultAddress>(),
      ),
    )
    ..registerFactory<AuthCubit>(
      () => AuthCubit(
        serviceLocator<GetCurrentUser>(),
        serviceLocator<SignIn>(),
        serviceLocator<SignOut>(),
        createAccount: serviceLocator<CreateAccount>(),
        resetPassword: serviceLocator<ResetPassword>(),
        users: serviceLocator<AuthRepository>().watchUser(),
        isDemo: store == null,
      ),
    )
    ..registerFactory<BrandCubit>(
      () => BrandCubit(
        serviceLocator<GetBrand>(),
        serviceLocator<IsFollowingBrand>(),
        serviceLocator<ToggleBrandFollow>(),
        serviceLocator<SearchProducts>(),
      ),
    )
    ..registerFactory<FollowingBrandsCubit>(
      () => FollowingBrandsCubit(
        serviceLocator<GetFollowingBrands>(),
      ),
    )
    ..registerFactory<CatalogBrowseCubit>(
      () => CatalogBrowseCubit(serviceLocator<SearchProducts>()),
    )
    ..registerFactory<HomeCubit>(
      () => HomeCubit(serviceLocator<GetHomeCatalog>()),
    )
    ..registerFactory<PromotionsCubit>(
      () => PromotionsCubit(
        serviceLocator<GetAppliedPromotion>(),
        serviceLocator<ApplyPromotionCode>(),
        serviceLocator<ClearPromotion>(),
      ),
    )
    ..registerFactory<RecentlyViewedCubit>(
      () => RecentlyViewedCubit(
        serviceLocator<GetRecentlyViewed>(),
        serviceLocator<TrackRecentlyViewed>(),
      ),
    )
    ..registerFactory<WishlistCubit>(
      () => WishlistCubit(
        serviceLocator<GetWishlist>(),
        serviceLocator<ToggleWishlist>(),
      ),
    )
    ..registerFactory<ProductDetailsCubit>(
      () => ProductDetailsCubit(
        serviceLocator<GetProductDetails>(),
        serviceLocator<GetCompleteLook>(),
        serviceLocator<GetProductReviews>(),
        serviceLocator<SubmitProductReview>(),
        serviceLocator<AddToCart>(),
        serviceLocator<SubscribeBackInStock>(),
      ),
    )
    ..registerFactory<SearchCubit>(
      () => SearchCubit(serviceLocator<SearchProducts>()),
    )
    ..registerFactory<CartCubit>(
      () => CartCubit(
        serviceLocator<GetCart>(),
        serviceLocator<ChangeCartQuantity>(),
        serviceLocator<RemoveCartItem>(),
      ),
    )
    ..registerFactory<CheckoutCubit>(
      () => CheckoutCubit(
        serviceLocator<GetCart>(),
        serviceLocator<GetCheckoutOptions>(),
        serviceLocator<GetAppliedPromotion>(),
        serviceLocator<GetDefaultAddress>(),
        serviceLocator<PlaceOrder>(),
        serviceLocator<ClearCart>(),
        isCurrentAccount:
            store == null ? null : (uid) => store.auth.currentUser?.uid == uid,
        submissionIdFactory: store == null
            ? null
            : () => store.collection('demoOrders').doc().id,
      ),
    )
    ..registerFactory<OnboardingCubit>(
      () => OnboardingCubit(
        serviceLocator<SaveShoppingPreferences>(),
      ),
    )
    ..registerFactory<NotificationsCubit>(
      () => NotificationsCubit(
        serviceLocator<GetNotifications>(),
        serviceLocator<MarkNotificationsRead>(),
      ),
    )
    ..registerFactory<OrdersCubit>(
      () => OrdersCubit(serviceLocator<GetOrders>()),
    )
    ..registerFactory<OrderDetailsCubit>(
      () => OrderDetailsCubit(
        serviceLocator<GetOrderDetails>(),
        serviceLocator<RequestReturn>(),
      ),
    );
}
