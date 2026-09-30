import 'package:fashion_e_commerce/features/cart/data/datasources/cart_data_source.dart';
import 'package:fashion_e_commerce/features/cart/data/datasources/in_memory_cart_data_source.dart';
import 'package:fashion_e_commerce/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:fashion_e_commerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/add_to_cart.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/change_cart_quantity.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/get_cart.dart';
import 'package:fashion_e_commerce/features/cart/domain/usecases/remove_cart_item.dart';
import 'package:fashion_e_commerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/data/datasources/catalog_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/data/datasources/demo_catalog_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:fashion_e_commerce/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_home_catalog.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_product_details.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/product_details_cubit.dart';
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
    ..registerFactory<HomeCubit>(
      () => HomeCubit(serviceLocator<GetHomeCatalog>()),
    )
    ..registerFactory<ProductDetailsCubit>(
      () => ProductDetailsCubit(
        serviceLocator<GetProductDetails>(),
        serviceLocator<AddToCart>(),
      ),
    )
    ..registerFactory<CartCubit>(
      () => CartCubit(
        serviceLocator<GetCart>(),
        serviceLocator<ChangeCartQuantity>(),
        serviceLocator<RemoveCartItem>(),
      ),
    );
}
