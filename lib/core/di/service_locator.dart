import 'package:fashion_e_commerce/features/catalog/data/datasources/catalog_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/data/datasources/demo_catalog_data_source.dart';
import 'package:fashion_e_commerce/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:fashion_e_commerce/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_home_catalog.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/home_cubit.dart';
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
    ..registerFactory<HomeCubit>(
      () => HomeCubit(serviceLocator<GetHomeCatalog>()),
    );
}
