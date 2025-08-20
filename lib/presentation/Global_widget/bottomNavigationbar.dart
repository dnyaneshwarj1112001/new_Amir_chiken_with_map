import 'package:meatzo/screens/Mycart/Screens/MyCartScreen.dart';
import 'package:flutter/material.dart';
import 'package:meatzo/screens/Screen/HomeScrens/home_page_screen.dart';

import 'package:meatzo/screens/Order/My_Order.dart';
import 'package:meatzo/screens/Order/Profile/profileScreen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int selectedIndex = 0;

  void onTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List<Widget> pages = [
    const HomePageScreen(),
    const MyCardScreen(),
    const OrderDetailsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (selectedIndex == 0) {
          bool exitApp = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Exit App"),
              content: const Text("Are you sure you want to exit?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Yes"),
                ),
              ],
            ),
          );
          return exitApp;
        } else {
          setState(() {
            selectedIndex = 0;
          });
          return false;
        }
      },
      child: Scaffold(
        body: pages[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF9A292F),
          currentIndex: selectedIndex,
          onTap: onTapped,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: "MyCart"),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping), label: "Order"),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
