import 'package:fashion_e_commerce/core/localization/locale_cubit.dart';
import 'package:fashion_e_commerce/features/auth/data/datasources/auth_data_source.dart';
import 'package:fashion_e_commerce/features/auth/data/datasources/in_memory_auth_data_source.dart';
import 'package:fashion_e_commerce/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fashion_e_commerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/get_current_user.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/sign_in.dart';
import 'package:fashion_e_commerce/features/auth/domain/usecases/sign_out.dart';
import 'package:fashion_e_commerce/features/auth/presentation/cubit/auth_cubit.dart';
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
import 'package:fashion_e_commerce/features/orders/data/datasources/in_memory_orders_data_source.dart';
import 'package:fashion_e_commerce/features/orders/data/datasources/orders_data_source.dart';
import 'package:fashion_e_commerce/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:fashion_e_commerce/features/orders/domain/repositories/orders_repository.dart';
import 'package:fashion_e_commerce/features/orders/domain/usecases/get_order_details.dart';
import 'package:fashion_e_commerce/features/orders/domain/usecases/get_orders.dart';
import 'package:fashion_e_commerce/features/orders/domain/usecases/request_return.dart';
import 'package:fashion_e_commerce/features/orders/presentation/cubit/order_details_cubit.dart';
import 'package:fashion_e_commerce/features/orders/presentation/cubit/orders_cubit.dart';
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

void configureDependencies() {
  if (serviceLocator.isRegistered<HomeCubit>()) return;

  serviceLocator
    ..registerLazySingleton<AuthDataSource>(
      InMemoryAuthDataSource.new,
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator<AuthDataSource>()),
    )
    ..registerLazySingleton<GetCurrentUser>(
      () => GetCurrentUser(serviceLocator<AuthRepository>()),
    )
    ..registerLazySingleton<SignIn>(
      () => SignIn(serviceLocator<AuthRepository>()),
    )
    ..registerLazySingleton<SignOut>(
      () => SignOut(serviceLocator<AuthRepository>()),
    )
    ..registerLazySingleton<CatalogDataSource>(
      DemoCatalogDataSource.new,
    )
    ..registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(serviceLocator<CatalogDataSource>()),
    )
    ..registerLazySingleton<GetHomeCatalog>(
      () => GetHomeCatalog(serviceLocator<CatalogRepository>()),
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
      InMemoryCartDataSource.new,
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
    ..registerLazySingleton<ReviewsDataSource>(
      InMemoryReviewsDataSource.new,
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
      InMemoryWishlistDataSource.new,
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
      InMemoryNotificationsDataSource.new,
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
      InMemoryOrdersDataSource.new,
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
      DemoCheckoutDataSource.new,
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
    ..registerFactory<AuthCubit>(
      () => AuthCubit(
        serviceLocator<GetCurrentUser>(),
        serviceLocator<SignIn>(),
        serviceLocator<SignOut>(),
      ),
    )
    ..registerFactory<CatalogBrowseCubit>(
      () => CatalogBrowseCubit(serviceLocator<SearchProducts>()),
    )
    ..registerFactory<HomeCubit>(
      () => HomeCubit(serviceLocator<GetHomeCatalog>()),
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
        serviceLocator<PlaceOrder>(),
        serviceLocator<ClearCart>(),
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
