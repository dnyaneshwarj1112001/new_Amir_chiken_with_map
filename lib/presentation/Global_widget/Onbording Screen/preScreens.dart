import 'package:meatzo/screens/AuthScreen/Phone_Auth_page.dart';
import 'package:flutter/material.dart';
import 'package:onboarding_intro_screen/onboarding_screen.dart';


class OnbordingScreen extends StatefulWidget {
  const OnbordingScreen({super.key});

  @override
  State<OnbordingScreen> createState() => _OnbordingScreenState();
}

class _OnbordingScreenState extends State<OnbordingScreen> {
  @override
  Widget build(BuildContext context) {
    return OnBoardingScreen(
      onSkip: () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const PhoneAuthScreen()));
      },
      showPrevNextButton: true,

      showIndicator: true,
      backgourndColor: Colors.white, // Fixed typo
      activeDotColor: Colors.blue,
      deactiveDotColor: Colors.grey,
      iconColor: Colors.black,
      leftIcon: Icons.arrow_circle_left_rounded,
      rightIcon: Icons.arrow_circle_right_rounded,
      iconSize: 30,
      pages: [
        OnBoardingModel(
          image: Image.asset("lib/innitiel_screens/images/Murga.png"),
          title: "Welcome",
          body:
              "It's a pleasure to meet you. We are excited that you're here so let's get started!",
        ),
        OnBoardingModel(
          image: Image.asset("lib/innitiel_screens/images/shopimg.jpg"),
          title: "Order Meat From Apni Dukan",
          body:
              "Order from the best local shops with easy, on-demand delivery.",
        ),
        OnBoardingModel(
          image: Image.asset("lib/innitiel_screens/images/scooter.jpg"),
          title: "All your favorites",
          body:
              "Order from the best local shops with easy, on-demand delivery.",
        ),
      ],
    );
  }
}
