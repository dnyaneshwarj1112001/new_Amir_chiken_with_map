import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meatzo/locationpopup/locationhandler.dart';
import 'package:meatzo/presentation/Global_widget/SplashScreen.dart';
import 'package:meatzo/presentation/Global_widget/app_routes.dart';
import 'package:meatzo/presentation/Global_widget/shop_content_wrapper.dart';
import 'package:meatzo/screens/Mycart/cubit/counter_cubit_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterCubitCubit(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Meatzo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
              textTheme: GoogleFonts.montserratTextTheme(),
            ),
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
            onGenerateRoute: (settings) {
              // Handle deep linking and dynamic routes
              if (settings.name != null &&
                  AppRoutes.routes.containsKey(settings.name)) {
                return MaterialPageRoute(
                  builder: AppRoutes.routes[settings.name]!,
                  settings: settings,
                );
              }

              // Handle shop and product routes with arguments
              if (settings.name == AppRoutes.shopDetails ||
                  settings.name == AppRoutes.productDetails ||
                  settings.name == AppRoutes.allShops) {
                final args = settings.arguments as Map<String, dynamic>? ?? {};
                return MaterialPageRoute(
                  builder: (context) {
                    if (settings.name == AppRoutes.shopDetails) {
                      return ShopContentWrapper(
                        routeType: 'shop-details',
                        arguments: args,
                      );
                    } else if (settings.name == AppRoutes.productDetails) {
                      return ShopContentWrapper(
                        routeType: 'product-details',
                        arguments: args,
                      );
                    } else if (settings.name == AppRoutes.allShops) {
                      return ShopContentWrapper(
                        routeType: 'all-shops',
                        arguments: args,
                      );
                    }
                    return const Scaffold(
                        body: Center(child: Text('Page not found')));
                  },
                  settings: settings,
                );
              }

              // Default fallback
              return MaterialPageRoute(
                builder: (context) => const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
