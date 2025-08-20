
import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';

class ReturnPolicyScreen extends StatelessWidget {
  const ReturnPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Return Policy",
        titleColor: Colors.white,
        titleFontWeight: FontWeight.bold,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "Meatzo Return Policy",
              "This Return Policy applies to all orders placed through Meatzo Android Application (\"App\") and the website (meatzo.com). By placing an order, you agree to the terms set forth below.",
            ),
            _buildSection(
              "Return Eligibility",
              "We accept returns for the following reasons:\n\n"
                  "• Product quality issues (spoiled, damaged, or incorrect items)\n"
                  "• Wrong items delivered\n"
                  "• Significant quality concerns\n\n"
                  "Returns must be reported within 2 hours of delivery to be eligible for a refund or replacement.",
            ),
            _buildSection(
              "Return Process",
              "To initiate a return:\n\n"
                  "1. Contact our customer service immediately at +91 9325279918\n"
                  "2. Provide your order number and reason for return\n"
                  "3. Our team will assess the situation and guide you through the process",
            ),
            _buildSection(
              "Refund Policy",
              "Once your return is approved:\n\n"
                  "• Refunds will be processed within 5-7 business days\n"
                  "• The refund will be issued to your original payment method\n"
                  "• Delivery charges are non-refundable unless the return is due to our error",
            ),
            _buildSection(
              "Quality Standards",
              "We maintain strict quality standards for all our meat products. If you receive any product that doesn't meet our quality standards, please:\n\n"
                  "• Do not consume the product\n"
                  "• Take clear photos of the issue\n"
                  "• Contact us immediately",
            ),
            _buildSection(
              "Changes to this Return Policy",
              "Meatzo reserves the right to update this Return Policy at any time. We encourage you to review this page periodically to stay informed about any changes. Any changes made will not affect orders that have already been placed before the update.",
            ),
            _buildSection(
              "Contacting Us",
              "If you have any questions about this Return Policy or need assistance with your return, please contact us at meatzo123@gmail.com or call us at +91 9325279918.",
              fontSize:
                  16, 
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
