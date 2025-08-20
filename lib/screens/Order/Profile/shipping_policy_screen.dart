import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';

class ShippingPolicyScreen extends StatelessWidget {
  const ShippingPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Shipping Policy",
        titleColor: Colors.white,
        titleFontWeight: FontWeight.bold,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "Meatzo Shipping Policy",
              "This Shipping Policy applies to all orders placed through Meatzo Android Application (\"App\") and the website (meatzo.com). By placing an order, you agree to the terms set forth below.",
            ),
            _buildSection(
              "Delivery Time",
              "We pride ourselves on our quick delivery service. All orders are delivered within 40-45 minutes from the time of order placement. Our delivery times may vary slightly during peak hours or special occasions, but we always strive to maintain our quick delivery promise.",
            ),
            _buildSection(
              "Delivery Areas",
              "We currently deliver to select areas within our service radius. Delivery charges may vary based on your location. The exact delivery fee will be calculated and displayed at checkout before you place your order.",
            ),
            _buildSection(
              "Order Tracking",
              "Once your order is confirmed, you can track your delivery in real-time through our app. You'll receive regular updates about your order status, from preparation to delivery.",
            ),
            _buildSection(
              "Shipping Delays",
              "While we aim to maintain our quick delivery promise, there might be occasional delays due to traffic conditions, weather, or high order volumes. In such cases, we will keep you informed about any changes to your delivery time.",
            ),
            _buildSection(
              "Quality Assurance",
              "We ensure that all our meat products are delivered fresh and at the right temperature. If you have any concerns about the quality of your delivery, please contact us immediately.",
            ),
            _buildSection(
              "Changes to this Shipping Policy",
              "Meatzo reserves the right to update this Shipping Policy at any time. We encourage you to review this page periodically to stay informed about any changes. Any changes made will not affect orders that have already been placed before the update.",
            ),
            _buildSection(
              "Contacting Us",
              "If you have any questions about this Shipping Policy or need assistance with your order, please contact us at meatzo123@gmail.com or call us at +91 9325279918.",
              fontSize: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                "This document was last updated on April 24, 2024.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, {double fontSize = 20}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
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
