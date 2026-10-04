import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:fashion_e_commerce/features/addresses/presentation/pages/addresses_page.dart';
import 'package:fashion_e_commerce/features/auth/presentation/pages/account_page.dart';
import 'package:fashion_e_commerce/features/auth/presentation/pages/sign_in_page.dart';
import 'package:fashion_e_commerce/features/brands/presentation/cubit/brand_cubit.dart';
import 'package:fashion_e_commerce/features/brands/presentation/pages/brand_page.dart';
import 'package:fashion_e_commerce/features/brands/presentation/cubit/following_brands_cubit.dart';
import 'package:fashion_e_commerce/features/brands/presentation/pages/following_brands_page.dart';
import 'package:fashion_e_commerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:fashion_e_commerce/features/cart/presentation/pages/cart_page.dart';
import 'package:fashion_e_commerce/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:fashion_e_commerce/features/checkout/presentation/pages/checkout_page.dart';
import 'package:fashion_e_commerce/features/catalog/domain/entities/product_search_criteria.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/catalog_browse_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/product_details_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/cubit/search_cubit.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/discover_page.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/home_page.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/product_details_page.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/search_page.dart';
import 'package:fashion_e_commerce/features/catalog/presentation/pages/shop_page.dart';
import 'package:fashion_e_commerce/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:fashion_e_commerce/features/notifications/presentation/pages/notifications_page.dart';
import 'package:fashion_e_commerce/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:fashion_e_commerce/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:fashion_e_commerce/features/orders/presentation/cubit/order_details_cubit.dart';
import 'package:fashion_e_commerce/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:fashion_e_commerce/features/orders/presentation/pages/order_details_page.dart';
import 'package:fashion_e_commerce/features/orders/presentation/pages/orders_page.dart';
import 'package:fashion_e_commerce/features/splash/presentation/pages/initial_splash_page.dart';
import 'package:fashion_e_commerce/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      Routes.initialSplash => _page(const InitialSplashPage(), settings),
      Routes.onboarding => _page(
          BlocProvider<OnboardingCubit>(
            create: (_) => serviceLocator<OnboardingCubit>(),
            child: const OnboardingPage(),
          ),
          settings,
        ),
      Routes.home => _page(
          BlocProvider<HomeCubit>(
            create: (_) => serviceLocator<HomeCubit>()..load(),
            child: const HomePage(),
          ),
          settings,
        ),
      Routes.productDetails => _productDetailsRoute(settings),
      Routes.brand => _brandRoute(settings),
      Routes.followingBrands => _page(
          BlocProvider<FollowingBrandsCubit>(
            create: (_) => serviceLocator<FollowingBrandsCubit>()..load(),
            child: const FollowingBrandsPage(),
          ),
          settings,
        ),
      Routes.cart => _page(
          BlocProvider<CartCubit>(
            create: (_) => serviceLocator<CartCubit>()..load(),
            child: const CartPage(),
          ),
          settings,
        ),
      Routes.checkout => _page(
          BlocProvider<CheckoutCubit>(
            create: (_) => serviceLocator<CheckoutCubit>()..load(),
            child: const CheckoutPage(),
          ),
          settings,
        ),
      Routes.search => _searchRoute(settings),
      Routes.shop => _page(
          BlocProvider<CatalogBrowseCubit>(
            create: (_) => serviceLocator<CatalogBrowseCubit>()..load(),
            child: const ShopPage(),
          ),
          settings,
        ),
      Routes.discover => _page(
          BlocProvider<CatalogBrowseCubit>(
            create: (_) => serviceLocator<CatalogBrowseCubit>()..load(),
            child: const DiscoverPage(),
          ),
          settings,
        ),
      Routes.wishlist => _page(const WishlistPage(), settings),
      Routes.notifications => _page(
          BlocProvider<NotificationsCubit>(
            create: (_) => serviceLocator<NotificationsCubit>()..load(),
            child: const NotificationsPage(),
          ),
          settings,
        ),
      Routes.orders => _page(
          BlocProvider<OrdersCubit>(
            create: (_) => serviceLocator<OrdersCubit>()..load(),
            child: const OrdersPage(),
          ),
          settings,
        ),
      Routes.orderDetails => _orderDetailsRoute(settings),
      Routes.account => _page(const AccountPage(), settings),
      Routes.addresses => _page(
          BlocProvider<AddressesCubit>(
            create: (_) => serviceLocator<AddressesCubit>()..load(),
            child: const AddressesPage(),
          ),
          settings,
        ),
      Routes.signIn => _page(const SignInPage(), settings),
      _ => _unknownRoute(settings),
    };
  }

  static MaterialPageRoute<dynamic> _brandRoute(
    RouteSettings settings,
  ) {
    final brandName = settings.arguments;

    if (brandName is! String || brandName.isEmpty) {
      return _unknownRoute(settings);
    }

    return _page(
      BlocProvider<BrandCubit>(
        create: (_) => serviceLocator<BrandCubit>()..load(brandName),
        child: const BrandPage(),
      ),
      settings,
    );
  }

  static MaterialPageRoute<dynamic> _searchRoute(
    RouteSettings settings,
  ) {
    final criteria = settings.arguments is ProductSearchCriteria
        ? settings.arguments! as ProductSearchCriteria
        : const ProductSearchCriteria();

    return _page(
      BlocProvider<SearchCubit>(
        create: (_) => serviceLocator<SearchCubit>()..load(criteria),
        child:
            SearchPage(autofocus: settings.arguments is! ProductSearchCriteria),
      ),
      settings,
    );
  }

  static MaterialPageRoute<dynamic> _orderDetailsRoute(
    RouteSettings settings,
  ) {
    final orderId = settings.arguments;

    if (orderId is! String || orderId.isEmpty) {
      return _unknownRoute(settings);
    }

    return _page(
      BlocProvider<OrderDetailsCubit>(
        create: (_) => serviceLocator<OrderDetailsCubit>()..load(orderId),
        child: const OrderDetailsPage(),
      ),
      settings,
    );
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
        create: (_) => serviceLocator<ProductDetailsCubit>()..load(productId),
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
