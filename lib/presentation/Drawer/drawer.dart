import 'package:meatzo/screens/AuthScreen/Phone_Auth_page.dart';

import 'package:meatzo/screens/Order/OrderRecipt1.dart';
import 'package:meatzo/screens/Order/Profile/profileScreen.dart';
import 'package:meatzo/presentation/Global_widget/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerExample extends StatelessWidget {
  const DrawerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black, // Set drawer background to black
      child: Column(
        children: [
          const SizedBox(height: 40), // Space from top
          const Divider(color: Colors.white), // White divider
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white), // White icon
            title: const Text(
              "Home",
              style: TextStyle(color: Colors.white), // White text
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.white),
            title: const Text(
              "Mycart",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, AppRoutes.myCard);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.white),
            title: const Text(
              "Order",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const OrderRecipt()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notification_add_outlined,
                color: Colors.white),
            title: const Text(
              "Notification",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const OrderRecipt()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle, color: Colors.white),
            title: const Text(
              "profile",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove("auth_token");

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PhoneAuthScreen()),
                  (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
