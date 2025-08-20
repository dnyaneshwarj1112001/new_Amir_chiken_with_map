import 'package:meatzo/presentation/Global_widget/bottomNavigationbar.dart';
import 'package:meatzo/presentation/Global_widget/shop_content_wrapper.dart';
import 'package:meatzo/screens/AuthScreen/Phone_Auth_page.dart';
import 'package:meatzo/screens/Mycart/Screens/MyCartScreen.dart';
import 'package:meatzo/screens/Order/My_Order.dart';
import 'package:meatzo/screens/Order/Profile/refund_policy_screen.dart';
import 'package:meatzo/screens/Order/Profile/return_policy_screen.dart';
import 'package:meatzo/screens/Order/Profile/shipping_policy_screen.dart';
import 'package:meatzo/screens/Screen/HomeScrens/home_page_screen.dart';
import 'package:meatzo/screens/Order/Profile/terms_and_conditions_screen.dart';
import 'package:meatzo/screens/Order/Profile/profileScreen.dart';
import 'package:meatzo/presentation/Global_widget/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:meatzo/screens/Order/Profile/account_settings_screen.dart';
import 'package:meatzo/screens/Order/Profile/privacy_policy_screen.dart';
import 'package:meatzo/screens/Order/Profile/settings_screen.dart';

class AppRoutes {
  // Main navigation routes (with bottom nav bar)
  static const String home = '/';
  static const String myCart = '/cart';
  static const String order = '/order';
  static const String profile = '/profile';

  // Shop and Product routes (with bottom nav bar)
  static const String shopDetails = '/shop-details';
  static const String productDetails = '/product-details';
  static const String allShops = '/all-shops';

  // Auth routes
  static const String splash = '/splash';
  static const String phoneAuth = '/phone-auth';

  // Profile sub-routes (these will be shown within the profile tab)
  static const String settings = '/settings';
  static const String privacyPolicy = '/privacy-policy';
  static const String accountSettings = '/account-settings';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String returnPolicy = '/return-policy';
  static const String refundPolicy = '/refund-policy';
  static const String shippingPolicy = '/shipping-policy';

  static Map<String, WidgetBuilder> routes = {
    // Main routes with bottom navigation
    home: (context) => const NavBar(initialIndex: 0),
    myCart: (context) => const NavBar(initialIndex: 1),
    order: (context) => const NavBar(initialIndex: 2),
    profile: (context) => const NavBar(initialIndex: 3),

    // Shop and Product routes are handled by onGenerateRoute in main.dart
    // This ensures proper argument handling and ShopContentWrapper usage

    // Auth routes
    splash: (context) => const SplashScreen(),
    phoneAuth: (context) => const PhoneAuthScreen(),

    // Profile sub-routes (these will be handled by the profile tab)
    settings: (context) => const SettingsScreen(),
    termsAndConditions: (context) => const TermsAndConditionsScreen(),
    privacyPolicy: (context) => const PrivacyPolicyScreen(),
    shippingPolicy: (context) => const ShippingPolicyScreen(),
    returnPolicy: (context) => const ReturnPolicyScreen(),
    refundPolicy: (context) => const RefundPolicyScreen(),
    accountSettings: (context) => const AccountSettingsScreen(),
  };

  // Navigation helper methods
  static void navigateToTab(BuildContext context, int tabIndex) {
    switch (tabIndex) {
      case 0:
        Navigator.pushReplacementNamed(context, home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, myCart);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, order);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, profile);
        break;
    }
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, home);
  }

  static void navigateToCart(BuildContext context) {
    Navigator.pushReplacementNamed(context, myCart);
  }

  static void navigateToOrder(BuildContext context) {
    Navigator.pushReplacementNamed(context, order);
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushReplacementNamed(context, profile);
  }

  // Shop and Product navigation methods
  static void navigateToShopDetails(
    BuildContext context, {
    required String shopId,
    required String shopName,
    required String images,
    required String deliveryIn,
    required String closedAt,
    required String openAt,
    required String latitude,
    required String lagitude,
  }) {
    Navigator.pushNamed(
      context,
      shopDetails,
      arguments: {
        'shopId': shopId,
        'shopName': shopName,
        'images': images,
        'deliveryIn': deliveryIn,
        'closedAt': closedAt,
        'openAt': openAt,
        'latitude': latitude,
        'lagitude': lagitude,
      },
    );
  }

  static void navigateToProductDetails(
    BuildContext context, {
    required int categoryId,
    required String categoryName,
  }) {
    Navigator.pushNamed(
      context,
      productDetails,
      arguments: {
        'categoryId': categoryId,
        'categoryName': categoryName,
      },
    );
  }

  static void navigateToAllShops(BuildContext context,
      {List<dynamic> shops = const []}) {
    Navigator.pushNamed(
      context,
      allShops,
      arguments: {'shops': shops},
    );
  }
}

// Navigation service for better tab management
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static NavigationService get instance => _instance;

  // Navigate to specific tab with smooth transition
  void navigateToTab(BuildContext context, int tabIndex) {
    AppRoutes.navigateToTab(context, tabIndex);
  }

  // Navigate to home tab
  void goToHome(BuildContext context) {
    AppRoutes.navigateToHome(context);
  }

  // Navigate to cart tab
  void goToCart(BuildContext context) {
    AppRoutes.navigateToCart(context);
  }

  // Navigate to order tab
  void goToOrder(BuildContext context) {
    AppRoutes.navigateToOrder(context);
  }

  // Navigate to profile tab
  void goToProfile(BuildContext context) {
    AppRoutes.navigateToProfile(context);
  }

  // Shop and Product navigation
  void goToShopDetails(
    BuildContext context, {
    required String shopId,
    required String shopName,
    required String images,
    required String deliveryIn,
    required String closedAt,
    required String openAt,
    required String latitude,
    required String lagitude,
  }) {
    AppRoutes.navigateToShopDetails(
      context,
      shopId: shopId,
      shopName: shopName,
      images: images,
      deliveryIn: deliveryIn,
      closedAt: closedAt,
      openAt: openAt,
      latitude: latitude,
      lagitude: lagitude,
    );
  }

  void goToProductDetails(
    BuildContext context, {
    required int categoryId,
    required String categoryName,
  }) {
    AppRoutes.navigateToProductDetails(
      context,
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }

  void goToAllShops(BuildContext context, {List<dynamic> shops = const []}) {
    AppRoutes.navigateToAllShops(context, shops: shops);
  }

  // Navigate to profile sub-pages (these will be shown as overlays)
  void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  void navigateToPrivacyPolicy(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.privacyPolicy);
  }

  void navigateToAccountSettings(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.accountSettings);
  }

  void navigateToTermsAndConditions(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.termsAndConditions);
  }

  void navigateToReturnPolicy(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.returnPolicy);
  }

  void navigateToRefundPolicy(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.refundPolicy);
  }

  void navigateToShippingPolicy(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.shippingPolicy);
  }
}
