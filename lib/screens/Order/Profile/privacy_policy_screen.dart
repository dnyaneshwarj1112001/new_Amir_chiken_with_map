import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Privacy Policy",
        titleColor: Colors.white,
        titleFontWeight: FontWeight.bold,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "Meatzo Privacy Policy",
              "At Meatzo, we are committed to protecting your privacy. This Privacy Policy outlines how we collect, use, and safeguard your information when you visit our website, https://meatzo.com.",
            ),
            _buildSection(
              "1. Information We Collect",
              "Website:\n\n"
                  "• Personal Information: When you place an order or sign up on our website, we may collect your name, contact information, and shipping address.\n"
                  "• Payment Information: We do not store any payment information. All payment transactions are securely processed by Razorpay.\n"
                  "• Cookies: We use cookies to enhance your experience on our website and to track site usage.\n\n"
                  "App:\n\n"
                  "• Personal Information: The app may collect your name, contact information, and shipping address when you create an account or place an order.\n"
                  "• Device Information: We do not collect or use your device's Advertising ID or any other personal identifiers from your device.\n"
                  "• Location Information: The app does not collect location data.\n"
                  "• Payment Information: As with the website, payment information is securely processed by Razorpay, and no payment details are stored by us.",
            ),
            _buildSection(
              "2. How We Use Your Information",
              "For Website and App:\n\n"
                  "• To process and fulfill your orders.\n"
                  "• To send you updates on your order and marketing communications (if you opt-in).\n"
                  "• To improve our website, app, and customer experience.",
            ),
            _buildSection(
              "3. Sharing Your Information",
              "We do not sell, trade, or share your personal information with third parties, except as required for payment processing, order fulfillment, or as required by law.",
            ),
            _buildSection(
              "4. Data Security",
              "We implement industry-standard security measures to protect your personal data. However, no method of transmission over the internet or through mobile applications is completely secure, and we cannot guarantee absolute security.",
            ),
            _buildSection(
              "5. App Permissions",
              "• Internet Access: The app requires internet access to function, enabling order placement and communication with our servers.\n"
                  "• Storage: The app may request storage permissions to temporarily store content such as images and cache for improved user experience.\n"
                  "• No Collection of Sensitive Data: The app does not request access to sensitive data such as contacts, camera, microphone, or location services.",
            ),
            _buildSection(
              "6. Changes to Privacy Policy",
              "We may update this Privacy Policy from time to time. Changes will be posted on this page with an updated \"Effective Date.\"",
            ),
            _buildSection(
              "7. Contact Us",
              "If you have any questions regarding this Privacy Policy, please contact us at:\n\n"
                  "Sarve No-51, Plot No-15, Dhanori Road,\n"
                  "Near Hema Bangles, Munjabawasti, Dhanori,\n"
                  "VTC: Pune City, PO: Dighi Camp, Sub District: Pune City, District: Pune.\n"
                  "Phone: +91 9325279918\n"
                  "Email: meatzo123@gmail.com",
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Appcolor.primaryRed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 32),
        ],
      ),
    );
  }
}
