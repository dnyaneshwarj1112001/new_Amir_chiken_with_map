import 'dart:async';

import 'package:meatzo/presentation/Global_widget/bottomNavigationbar.dart';
import 'package:meatzo/presentation/Global_widget/gap.dart';
import 'package:meatzo/presentation/Global_widget/Onbording%20Screen/preScreens.dart';
import 'package:meatzo/screens/Screen/HomeScrens/home_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void navigatePage() {
    Timer(Duration(seconds: 4), () {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const OnbordingScreen()));
    });
  }

  checkloginstatus() async {
    Timer(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      print(token);
      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => NavBar()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => OnbordingScreen()));
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
      backgroundColor: Color(0xff9C141C),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
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
          Gaph(
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
