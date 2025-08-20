import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:meatzo/presentation/Global_widget/customechipbutton.dart';
import 'package:meatzo/presentation/Global_widget/app_routes.dart';
import 'package:meatzo/screens/Order/paymentScressn.dart';
import 'package:meatzo/screens/Order/My_Order.dart';
import 'package:meatzo/presentation/Global_widget/bottomNavigationbar.dart';

class OrderRecipt extends StatefulWidget {
  final double? price;
  final String? productName;
  final double? discount;
  final double? tax;
  final String? address;
  final String? mobile;

  const OrderRecipt({
    super.key,
    this.productName,
    this.price,
    this.discount,
    this.tax,
    this.address,
    this.mobile,
  });

  @override
  State<OrderRecipt> createState() => _OrderReciptState();
}

class _OrderReciptState extends State<OrderRecipt> {
  String _selectedPayment = "";
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
          return false;
        },
        child: Container(
          width: double.infinity,
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
                        MaterialPageRoute(
                            builder: (_) => const OrderDetailsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double subtotal = widget.price ?? 0.0;
    final double discount = widget.discount ?? 0.0;
    final double tax = widget.tax ?? 0.0;
    final double total = subtotal - discount + tax;

    return Scaffold(
      appBar: const CustomAppBar(title: "Order Receipt"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Apptext(
                        text: "Product Details", fontWeight: FontWeight.bold),
                    const Divider(),
                    ListTile(
                      leading:
                          const Icon(Icons.shopping_bag, color: Colors.blue),
                      title: Apptext(
                        text: widget.productName ?? "No Product",
                        fontWeight: FontWeight.w600,
                      ),
                      subtitle: Apptext(
                        text: "₹${subtotal.toStringAsFixed(2)}",
                      ),
                    ),
                    const Divider(),
                    const Apptext(
                        text: "Price Breakdown", fontWeight: FontWeight.bold),
                    const SizedBox(height: 8),
                    _buildPriceRow(
                        "Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
                    _buildPriceRow(
                        "Discount", "- ₹${discount.toStringAsFixed(2)}",
                        color: Colors.red),
                    _buildPriceRow("Tax", "+ ₹${tax.toStringAsFixed(2)}",
                        color: Colors.green),
                    const Divider(),
                    _buildPriceRow("Total Bill", "₹${total.toStringAsFixed(2)}",
                        isBold: true, fontSize: 18),
                    const SizedBox(height: 16),
                    const Apptext(
                        text: "Shipping Address", fontWeight: FontWeight.bold),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Apptext(
                        text: widget.address ?? "No address provided",
                      ),
                    ),
                    Apptext(
                      text: "Mobile: ${widget.mobile ?? "N/A"}",
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 16),
                    const Apptext(
                        text: "Payment Method", fontWeight: FontWeight.bold),
                    const Divider(),
                    _buildRadioButton("COD", "Cash On Delivery"),
                    _buildRadioButton("Online", "Online Payment"),
                    const SizedBox(height: 10),
                    CustomChipButton(
                      text: _isLoading ? "Placing Order..." : "Place Order",
                      onPressed: () {
                        if (_selectedPayment == "Online") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OnlinePaymentScreen(
                                amount: total,
                                Payment_mode: _selectedPayment,
                              ),
                            ),
                          ).then((result) async {
                            if (result != null &&
                                result is Map<String, dynamic>) {
                              await _placeOrder(
                                paymentMode: result['paymentMode'],
                                razorpayPaymentId: result['paymentId'],
                              );
                            }
                          });
                        } else if (_selectedPayment == "COD") {
                          _placeOrder(
                            paymentMode: _selectedPayment.toLowerCase(),
                          );
                        } else {
                          _showSnackBar("Please select a payment method");
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {bool isBold = false, double fontSize = 12, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Apptext(
            text: label,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            size: fontSize,
          ),
          Apptext(
            text: value,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
            size: fontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioButton(String value, String text) {
    bool isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPayment = value;
        });
      },
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedPayment,
            onChanged: (newValue) {
              setState(() {
                _selectedPayment = newValue!;
              });
            },
            activeColor: Colors.red,
          ),
          Apptext(
            text: text,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.red : Colors.black,
          ),
        ],
      ),
    );
  }
}
