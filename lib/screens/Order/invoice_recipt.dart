import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:meatzo/screens/Order/orderService/single_order_service.dart';
import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:meatzo/presentation/Global_widget/gap.dart';
import 'package:meatzo/presentation/Global_widget/bottomNavigationbar.dart';
import 'package:meatzo/presentation/Global_widget/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class Invoice_Recept extends StatefulWidget {
  final int orderId;
  const Invoice_Recept({super.key, required this.orderId});

  @override
  State<Invoice_Recept> createState() => _Invoice_ReceptState();
}

class _Invoice_ReceptState extends State<Invoice_Recept> {
  late Future<Map<String, dynamic>> _futureOrder;

  @override
  void initState() {
    super.initState();
    _futureOrder = SingleOrderService().fetchOrder(widget.orderId);
  }

  String _formatDate(String rawDate) {
    final date = DateTime.parse(rawDate);
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _generateReceiptText(Map<String, dynamic> order) {
    String productsText = '';
    for (var item in order['order_children']) {
      productsText +=
          '${item['product']['product_name']} (${item['child_product_size']}) - ₹${item['child_sale_price']} x ${item['child_product_qty']} = ₹${double.parse(item['child_sale_price']) * double.parse(item['child_product_qty'])}\n';
    }

    return '''
INVOICE RECEIPT
==============

Invoice No: ${order['tbl_order_code']}
Date: ${_formatDate(order["order_delivery_date"])}

INVOICE TO:
${order["order_user_address"] ?? "Unknown User"}
Mobile: ${order['customer']['mobile_number'] ?? "N/A"}

PAY TO:
${order['shop']['name'] ?? "Meatzo"}
Email: ${order['shop']['email'] ?? "meatzo123@gmail.com"}
Mobile: ${order['shop']['fcm_token'] ?? "+919325279918"}

PRODUCTS:
---------
$productsText

PAYMENT INFO:
------------
Customer: ${order['customer']['name'] ?? "Unknown User"}
Payment: ${order['bill_type'] == 'cod' ? 'Cash On Delivery' : order['bill_type']}
Amount: ₹${order['total_bill']}

AMOUNT BREAKDOWN:
----------------
Subtotal: ₹${order['total_sale_price']}
Discount: -₹${order['total_discount']}
Tax Amount: +₹${order['total_tax']}
Grand Total: ₹${order['total_bill']}

Terms & Conditions:
The Company reserves the right, at its discretion, to change, modify, add, or remove portions of these Terms at any time by posting the amended Terms.

''';
  }

  void _shareReceipt(Map<String, dynamic> order) {
    final String receiptText = _generateReceiptText(order);
    Share.share(receiptText,
        subject: 'Invoice Receipt - ${order['tbl_order_code']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Invoice Receipt",
        actions: [
          FutureBuilder<Map<String, dynamic>>(
            future: _futureOrder,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () => _shareReceipt(snapshot.data!),
                );
              }
              return Container();
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.order),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureOrder,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final order = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                                height: 60,
                                width: 200,
                                child: Image.asset(
                                    "lib/innitiel_screens/images/scooter.jpg")),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Apptext(
                                      text:
                                          "Invoice No: ${order['tbl_order_code']}",
                                      size: 12,
                                      fontWeight: FontWeight.bold),
                                  Apptext(
                                      text:
                                          "Date: ${_formatDate(order["order_delivery_date"])}",
                                      size: 12,
                                      fontWeight: FontWeight.bold),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 140,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Apptext(
                                      text: "Invoice To:",
                                      fontWeight: FontWeight.bold),
                                  Apptext(
                                    text: order["order_user_address"] ??
                                        "Unknown User",
                                  ),
                                  Apptext(
                                    text:
                                        "Mobile: +${order['customer']['mobile_number'] ?? "N/A"}",
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 1.5,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            const SizedBox(
                              width: 165,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Apptext(
                                      text: "Pay To: Meatzo",
                                      fontWeight: FontWeight.bold),
                                  Apptext(
                                    text: "Email: meatzo123@gmail.com",
                                    maxline: 1,
                                  ),
                                  Apptext(
                                    text: "Mobile: +919325279918",
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Apptext(
                                    text: "Product",
                                    fontWeight: FontWeight.bold),
                                Apptext(
                                    text: "Size", fontWeight: FontWeight.bold),
                                Apptext(
                                    text: "Sale Price",
                                    fontWeight: FontWeight.bold),
                                Apptext(
                                    text: "Qty", fontWeight: FontWeight.bold),
                                Apptext(
                                    text: "Amount",
                                    fontWeight: FontWeight.bold),
                              ],
                            ),
                            const Divider(),
                            ...order['order_children'].map<Widget>((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Apptext(
                                        text: item['product']['product_name']),
                                    Apptext(text: item['child_product_size']),
                                    Apptext(
                                        text: "₹${item['child_sale_price']}"),
                                    Apptext(text: item['child_product_qty']),
                                    Apptext(
                                        text:
                                            "₹${double.parse(item['child_sale_price']) * double.parse(item['child_product_qty'])}"),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Apptext(
                                    text: "Payment Info:",
                                    size: 14,
                                    fontWeight: FontWeight.bold),
                                Apptext(
                                    text:
                                        "Customer: ${order['customer']['name'] ?? "Unknown User"}",
                                    size: 12),
                                Apptext(
                                    text:
                                        "Payment: ${order['bill_type'] == 'cod' ? 'Cash On Delivery' : order['bill_type']}",
                                    size: 12),
                                Apptext(
                                    text: "Amount: ₹${order['total_bill']}",
                                    size: 12),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildAmountRow(
                                  "Subtotal", "₹${order['total_sale_price']}",
                                  textColor: Colors.green),
                              _buildAmountRow(
                                  "Discount", "- ₹${order['total_discount']}",
                                  textColor: Colors.green),
                              _buildAmountRow(
                                  "Tax Amount", "+ ₹${order['total_tax']}",
                                  textColor: Colors.red),
                              const Divider(),
                              Container(
                                  decoration:
                                      BoxDecoration(color: Colors.grey[200]),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: _buildAmountRow("Grand Total",
                                        "₹${order['total_bill']}",
                                        isBold: true),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Apptext(
                                text: "Terms & Conditions:",
                                fontWeight: FontWeight.bold),
                            Apptext(
                              text:
                                  "The Company reserves the right, at its discretion, to change, modify, "
                                  "add, or remove portions of these Terms at any time by posting the amended Terms.",
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No order data available.'));
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF9A292F),
        currentIndex: 2, // Order tab index
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.home);
              break;
            case 1:
              Navigator.pushReplacementNamed(context, AppRoutes.myCart);
              break;
            case 2:
              // Already on orders page
              break;
            case 3:
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'MyCart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String title, String value,
      {bool isBold = false, Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Apptext(
            text: title,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: textColor ?? Colors.black),
        const Gapw(width: 10),
        Apptext(
          text: value,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ],
    );
  }
}
