import 'package:meatzo/presentation/Global_widget/bottomNavigationbar.dart';
import 'package:meatzo/screens/AuthScreen/Phone_Auth_page.dart';
import 'package:meatzo/screens/Mycart/Screens/MyCartScreen.dart';
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
  static const String home = '/HomePageScreen';
  static const String myCard = '/MyCardScreen';
  static const String profile = '/ProfileScreen';
  static const String order = '/OrderScreen';
  static const String splash = '/SplashScreen';
  static const String nav = '/NavBar';
  static const String phoneauth = '/phoneauth';
  static const String settings = '/settings';
  static const String privacyPolicy = '/privacy-policy';
  static const String accountSettings = '/account-settings';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String returnPolicy = '/return-policy';
  static const String refundPolicy = '/refund-policy';
  static const String shippingPolicy = '/shipping-policy';
  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePageScreen(),
    myCard: (context) => const MyCardScreen(),
    profile: (context) => const ProfileScreen(),
    splash: (context) => const SplashScreen(),
    nav: (context) => const NavBar(),
    phoneauth: (context) => const PhoneAuthScreen(),
    settings: (context) => const SettingsScreen(),
    termsAndConditions: (context) => const TermsAndConditionsScreen(),
    privacyPolicy: (context) => const PrivacyPolicyScreen(),
    shippingPolicy: (context) => const ShippingPolicyScreen(),
    returnPolicy: (context) => const ReturnPolicyScreen(),
    refundPolicy: (context) => const RefundPolicyScreen(),
    accountSettings: (context) => const AccountSettingsScreen(),
  };
}
