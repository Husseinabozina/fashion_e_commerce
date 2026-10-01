import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/routing/app_router.dart';
import 'package:fashion_e_commerce/core/localization/locale_cubit.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fashion_e_commerce/features/promotions/presentation/cubit/promotions_cubit.dart';
import 'package:fashion_e_commerce/features/recently_viewed/presentation/cubit/recently_viewed_cubit.dart';
import 'package:fashion_e_commerce/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FashionApp extends StatelessWidget {
  const FashionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
                create: (_) => serviceLocator<AuthCubit>()..load()),
            BlocProvider<LocaleCubit>(
                create: (_) => serviceLocator<LocaleCubit>()),
          ],
          child: Builder(
              builder: (accountContext) =>
                  BlocSelector<AuthCubit, AuthState, String>(
                    selector: (_) =>
                        accountContext.read<AuthCubit>().sessionKey,
                    builder: (context, sessionKey) => KeyedSubtree(
                      key: ValueKey(sessionKey),
                      child: MultiBlocProvider(
                        providers: [
                          BlocProvider<WishlistCubit>(
                              create: (_) =>
                                  serviceLocator<WishlistCubit>()..load()),
                          BlocProvider<RecentlyViewedCubit>(
                              create: (_) =>
                                  serviceLocator<RecentlyViewedCubit>()
                                    ..load()),
                          BlocProvider<PromotionsCubit>(
                              create: (_) =>
                                  serviceLocator<PromotionsCubit>()..load()),
                        ],
                        child: BlocBuilder<LocaleCubit, Locale>(
                          builder: (context, locale) {
                            return MaterialApp(
                              title: 'Fashion E-Commerce',
                              debugShowCheckedModeBanner: false,
                              builder: (_, child) =>
                                  AnnotatedRegion<SystemUiOverlayStyle>(
                                value: SystemUiOverlayStyle.dark,
                                child: child!,
                              ),
                              locale: locale,
                              supportedLocales: const [
                                Locale('en'),
                                Locale('ar'),
                              ],
                              localizationsDelegates: const [
                                GlobalMaterialLocalizations.delegate,
                                GlobalWidgetsLocalizations.delegate,
                                GlobalCupertinoLocalizations.delegate,
                              ],
                              theme: AppTheme.lightThemeFor(locale),
                              initialRoute: Routes.initialSplash,
                              onGenerateRoute: AppRouter.onGenerateRoute,
                            );
                          },
                        ),
                      ),
                    ),
                  )),
        );
      },
    );
  }
}
