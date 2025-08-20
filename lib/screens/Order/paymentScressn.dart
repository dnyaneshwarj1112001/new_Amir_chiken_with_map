import 'dart:convert';

import 'package:meatzo/presentation/Global_widget/app_routes.dart';
import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:meatzo/presentation/Global_widget/bottomNavigationbar.dart';
import 'package:meatzo/presentation/Global_widget/customechipbutton.dart';
import 'package:meatzo/screens/Order/My_Order.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OnlinePaymentScreen extends StatefulWidget {
  final double amount;
  final String Payment_mode;

  const OnlinePaymentScreen({
    super.key,
    required this.amount,
    required this.Payment_mode,
  });

  @override
  State<OnlinePaymentScreen> createState() => _OnlinePaymentScreenState();
}

class _OnlinePaymentScreenState extends State<OnlinePaymentScreen> {
  late Razorpay _razorpay;
  bool _isLoading = false;
  Future<void> _placeOrder({
    required String paymentMode,
    String? razorpayPaymentId,
  }) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      const baseUrl = "https://meatzo.com/api/order";

      final Map<String, dynamic> body = {
        "payment_mode": paymentMode,
      };

      if (paymentMode == "online" && razorpayPaymentId != null) {
        body["razorpay_payment_id"] = razorpayPaymentId;
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': "Bearer $token",
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        _showSuccessDialog();
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_test_0ijlExrPtiV5Hx', // Test key
      'amount': (widget.amount * 100).toInt(), // in paise
      'name': 'Meatzo',
      'description': 'Order Payment',
      'currency': 'INR',
      'prefill': {
        'contact': '9999999999',
        'email': 'test@meatzo.com',
      }
    };

    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
 

    // Navigator.pop(context,
    //     {'paymentId': response.paymentId, 'paymentMode': widget.Payment_mode});
    _placeOrder(paymentMode: "online", razorpayPaymentId: response.paymentId);

    _showSuccessDialog();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful: ${response.paymentId}')),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showError(response.message ?? 'Payment Failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Now'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Amount to Pay',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                '₹${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Apptext(
                  text: 'Pay Now',
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: _startPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      // ignore: deprecated_member_use
      builder: (context) => WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacementNamed(context, AppRoutes.nav);
          return false;
        },
        child: AlertDialog(
          title: const Apptext(
              text: "Thank You for Your Order!", fontWeight: FontWeight.bold),
          content: const Apptext(
            text:
                "Your order has been successfully placed. Please go to View my order for live tracking.",
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomChipButton(
                  text: "BACK TO HOME",
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const NavBar()),
                    );
                  },
                ),
                CustomChipButton(
                  text: "VIEW MY ORDERS",
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const OrderDetailsScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
