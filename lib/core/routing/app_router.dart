import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:fashion_e_commerce/features/cart/presentation/pages/cart_page.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/product_details_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/home_page.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/product_details_page.dart';
import 'package:fashion_e_commerce/features/splash/presentation/pages/brand_reveal_splash_page.dart';
import 'package:fashion_e_commerce/features/splash/presentation/pages/initial_splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      Routes.initialSplash => _page(const InitialSplashPage(), settings),
      Routes.brandRevealSplash =>
        _page(const BrandRevealSplashPage(), settings),
      Routes.home => _page(
          BlocProvider<HomeCubit>(
            create: (_) => serviceLocator<HomeCubit>()..load(),
            child: const HomePage(),
          ),
          settings,
        ),
      Routes.productDetails => _productDetailsRoute(settings),
      Routes.cart => _page(
          BlocProvider<CartCubit>(
            create: (_) => serviceLocator<CartCubit>()..load(),
            child: const CartPage(),
          ),
          settings,
        ),
      _ => _unknownRoute(settings),
    };
  }

  static MaterialPageRoute<dynamic> _productDetailsRoute(
    RouteSettings settings,
  ) {
    final productId = settings.arguments;

    if (productId is! String || productId.isEmpty) {
      return _unknownRoute(settings);
    }

    return _page(
      BlocProvider<ProductDetailsCubit>(
        create: (_) =>
            serviceLocator<ProductDetailsCubit>()..load(productId),
        child: const ProductDetailsPage(),
      ),
      settings,
    );
  }

  static MaterialPageRoute<dynamic> _page(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }

  static MaterialPageRoute<dynamic> _unknownRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => Scaffold(
        body: Center(
          child: Text('Unknown route: ${settings.name}'),
        ),
      ),
    );
  }
}
