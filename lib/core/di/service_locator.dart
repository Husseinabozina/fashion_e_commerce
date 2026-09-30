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
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_home_catalog.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_product_details.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/search_products.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/product_details_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/search_cubit.dart';
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
    ..registerLazySingleton<CatalogDataSource>(
      DemoCatalogDataSource.new,
    )
    ..registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(serviceLocator<CatalogDataSource>()),
    )
    ..registerLazySingleton<GetHomeCatalog>(
      () => GetHomeCatalog(serviceLocator<CatalogRepository>()),
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
      () => PlaceOrder(serviceLocator<CheckoutRepository>()),
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
        serviceLocator<AddToCart>(),
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
    );
}
