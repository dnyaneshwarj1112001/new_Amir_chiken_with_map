import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';
import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:meatzo/presentation/Global_widget/gap.dart';
import 'package:meatzo/screens/AuthScreen/Phone_Auth_page.dart';
import 'package:meatzo/screens/Order/My_Order.dart';
import 'package:meatzo/screens/Screen/HomeScrens/home_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String profileUrl = '';
  String userMobile = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'Guest User';
      userEmail = prefs.getString('user_email') ?? '';
      userPhone = prefs.getString('user_phone') ?? '';
      userMobile = prefs.getString('user_mobile') ?? '';
      profileUrl = prefs.getString('profile_photo_url') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePageScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: const CustomAppBar(
          title: "Profile",
          titleColor: Colors.white,
          titleFontWeight: FontWeight.bold,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Gaph(height: 50),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileUrl.isNotEmpty
                          ? NetworkImage(profileUrl) as ImageProvider
                          : const AssetImage(
                              "lib/innitiel_screens/images/profileblank.png"),
                    ),
                    const SizedBox(height: 10),
                    Apptext(
                      text: userName,
                      color: Appcolor.primaryRed,
                      fontWeight: FontWeight.bold,
                      size: 20,
                    ),
                    const SizedBox(height: 5),
                    if (userMobile.isNotEmpty)
                      Apptext(
                        text: userMobile,
                        color: Appcolor.primaryRed,
                        fontWeight: FontWeight.w500,
                        size: 16,
                      ),
                    if (userEmail.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Apptext(
                        text: userEmail,
                        color: Appcolor.primaryRed,
                        fontWeight: FontWeight.w500,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildProfileOption(
                Icons.settings,
                "Settings",
                () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
              _buildProfileOption(
                Icons.lock,
                "Privacy Policy",
                () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
              ),
              _buildProfileOption(
                Icons.description,
                "Terms & Conditions",
                () =>
                    Navigator.pushNamed(context, AppRoutes.termsAndConditions),
              ),
              _buildProfileOption(
                
                Icons
                    .monetization_on_outlined, 
                "Refund Policy",
                () => Navigator.pushNamed(context, AppRoutes.refundPolicy),
              ),
              _buildProfileOption(
                
                Icons
                    .assignment_return_outlined, 
                "Return Policy",
                () => Navigator.pushNamed(context, AppRoutes.returnPolicy),
              ),
              _buildProfileOption(
                
                Icons
                    .local_shipping, 
                "Shipping Policy",
                () => Navigator.pushNamed(context, AppRoutes.shippingPolicy),
              ),
              _buildProfileOption(
                Icons.notification_add,
                "Notifications",
                () {
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon')),
                  );
                },
              ),
              _buildProfileOption(
                Icons.local_shipping_outlined,
                "Your Orders",
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderDetailsScreen(),
                  ),
                ),
              ),
              _buildProfileOption(
                Icons.person_outline,
                "Account Settings",
                () => Navigator.pushNamed(context, AppRoutes.accountSettings),
              ),
              _buildProfileOption(
                Icons.logout,
                "Logout",
                () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); 
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Appcolor.primaryRed,
        ),
        title: Apptext(
          text: title,
          fontWeight: FontWeight.w500,
          size: 16,
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
