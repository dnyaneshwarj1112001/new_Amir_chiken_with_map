import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';

class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Refund Policy",
        titleColor: Colors.white,
        titleFontWeight: FontWeight.bold,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "Meatzo Refund Policy",
              "At Meatzo, we aim to ensure your complete satisfaction with every purchase. If, for any reason, you are not satisfied with the product you receive, please review our refund policy below.",
            ),
            _buildSection(
              "1. Refund Eligibility",
              "• Refunds are applicable only for products that are damaged, defective, or incorrect at the time of delivery.\n"
                  "• Requests for refunds must be made within 48 hours of receiving the product.\n"
                  "• To process a refund, you must provide proof of purchase (order number, receipts) and photographic evidence of the product's condition.",
            ),
            _buildSection(
              "2. Non-Refundable Items",
              "• Perishable products, such as chicken and other food items, cannot be returned or refunded unless they are damaged or defective.\n"
                  "• Customized or personalized items are not eligible for refunds.",
            ),
            _buildSection(
              "3. Refund Process",
              "Once your refund request is approved, we will process the refund to your original method of payment within 2 business days after order cancellation. Please note that your bank may take additional time to reflect the refund in your account.\n\n"
                  "Important Note: Refunds are subject to a mandatory 15- or 30-day auto-locking period before being processed. This period ensures all conditions for refunds are met and prevents fraudulent transactions.",
            ),
            _buildSection(
              "4. Cancellation Policy",
              "Orders can be canceled before they are shipped. Once an order has been dispatched, it cannot be canceled. If your order is canceled, we will initiate a full refund within 2 business days.\n\n"
                  "Note: For canceled orders, the refund will also be subject to the 15- or 30-day auto-locking period.",
            ),
            _buildSection(
              "If you have any questions about this or need assistance with your return, please contact us at:",
              "Email: meatzo123@gmail.com or call us at +91 9325279918.",
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
