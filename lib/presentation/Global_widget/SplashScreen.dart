import 'dart:async';

import 'package:meatzo/presentation/Global_widget/bottomNavigationbar.dart';
import 'package:meatzo/presentation/Global_widget/gap.dart';
import 'package:meatzo/presentation/Global_widget/Onbording%20Screen/preScreens.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meatzo/presentation/Global_widget/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void navigatePage() {
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, AppRoutes.phoneAuth);
    });
  }

  checkloginstatus() async {
    Timer(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      if (token != null && token.isNotEmpty) {
        // Navigate to home with bottom navigation
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        // Navigate to onboarding
        Navigator.pushReplacementNamed(context, AppRoutes.phoneAuth);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // navigatePage();
    checkloginstatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff9C141C),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              height: 260,
              width: 260,
              child: Image.asset("lib/innitiel_screens/images/Murga.png"),
            ),
          ),
          const Text("meatzo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 60,
                fontFamily: 'KaushanScript',
              )),
          const Gaph(
            height: 10,
          ),
          const Text("Order Meat From Apni Dukan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontFamily: 'KaushanScript',
              ))
        ],
      ),
    );
  }
}
