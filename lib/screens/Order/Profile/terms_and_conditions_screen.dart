import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Terms and Conditions",
        titleColor: Colors.white,
        titleFontWeight: FontWeight.bold,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "Welcome to Meatzo.",
              "These terms and conditions outline the rules and regulations for the use of our website, located at https://meatzo.com.\n\n"
                  "By accessing this website, we assume you accept these terms and conditions. Do not continue to use Meatzo if you do not agree to all of the terms and conditions stated on this page.",
            ),
            _buildSection(
              "1. Website Use",
              "By using our website, you warrant that you are at least 18 years old or accessing the site under the supervision of a parent or legal guardian. The content of this website is for your general information and use only. We reserve the right to modify the website or these Terms and Conditions without prior notice.",
            ),
            _buildSection(
              "2. Pricing and Payment",
              "All product prices are in Indian Rupees (INR) and are inclusive of GST unless stated otherwise. We reserve the right to change prices at any time. Payments are processed securely through our payment gateway partner Razorpay.",
            ),
            _buildSection(
              "3. Orders and Cancellations",
              "Orders placed on Meatzo are subject to acceptance and availability. We reserve the right to refuse or cancel any order for any reason. If your order is canceled after payment, we will refund the full amount as per our refund policy.",
            ),
            _buildSection(
              "4. Shipping and Delivery",
              "We deliver across India. Shipping charges and delivery timelines are mentioned at checkout and may vary based on location and product weight. Delivery timelines are estimates and may be affected by external factors beyond our control.",
            ),
            _buildSection(
              "5. Intellectual Property",
              "All content on this website, including images, logos, text, and product descriptions, is the intellectual property of Gumahdhar Jaggery and Confectionery OPC Pvt Ltd. Unauthorized use of any content may give rise to a claim for damages.",
            ),
            _buildSection(
              "6. Limitation of Liability",
              "We do not guarantee that this website will always be available or that it will be free from errors. We will not be liable for any loss or damage arising from the use of this website.",
            ),
            _buildSection(
              "7. Governing Law",
              "These terms and conditions are governed by the laws of India. Any disputes arising out of or in connection with these terms shall be subject to the exclusive jurisdiction of the courts in Pune, Maharashtra.",
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
