import 'package:meatzo/helper/util.dart';
import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:meatzo/screens/AuthScreen/custome_Next_button.dart';
import 'package:meatzo/screens/Order/TrackOrderPage.dart';
import 'package:meatzo/screens/Order/orderService/myorderService.dart';
import 'package:meatzo/screens/Order/invoice_recipt.dart';
import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;

  Future<void> fetchOrders() async {
    final fetchedOrders = await OrderDetailq.fetchOrders();

    if (fetchedOrders != null) {
      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String rawDate) {
    final date = DateTime.parse(rawDate);
    return DateFormat('dd MMM yyyy').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Delivered":
        return Colors.green;
      case "Shipped":
        return Colors.blue;
      case "Processing":
        return Colors.orange;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    Util.pretty(orders);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomAppBar(
        title: "My Orders",
        titleColor: Colors.white,
        titleFontWeight: FontWeight.bold,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 10),
                      const Apptext(
                        text: "No Orders Found",
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final products = order['order_children'] ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Apptext(
                                  text: "Order ${order["order_master_id"]}",
                                  fontWeight: FontWeight.bold,
                                  size: 12,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                            order["bill_type"] ?? "")
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Apptext(
                                    text: order["bill_type"] == "cod"
                                        ? "Cash on Delivery"
                                        : "Online Payment",
                                    fontWeight: FontWeight.w600,
                                    size: 10,
                                    color:
                                        _getStatusColor(order["status"] ?? ""),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Apptext(
                              text: "Order Code: ${order["tbl_order_code"]}",
                              size: 10,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(height: 4),
                            Apptext(
                              text:
                                  "Date: ${formatDate(order["order_delivery_date"])}  •  Total Bill: Rs. ${order["total_bill"]}",
                              size: 10,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                CustomButton(
                                  height: 35,
                                  width: 90,
                                  text: "View Receipt",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Invoice_Recept(
                                                orderId:
                                                    order["order_master_id"],
                                              )),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                if (order['order_status'] ==
                                    "transporting") ...[
                                  CustomButton(
                                    height: 35,
                                    width: 90,
                                    text: "Track Order",
                                    onPressed: () {
                                      final double initialLat = double.tryParse(
                                              order['lat']?.toString() ??
                                                  '0.0') ??
                                          0.0;
                                      final double initialLng = double.tryParse(
                                              order['lng']?.toString() ??
                                                  '0.0') ??
                                          0.0;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TrackOrderMapPage(
                                            orderId: order["order_master_id"],
                                            initialLat: initialLat,
                                            initialLng: initialLng,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ]
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Apptext(
                              text: "Order Details",
                              fontWeight: FontWeight.bold,
                              size: 11,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: List<Widget>.generate(
                                  products.length,
                                  (i) {
                                    final item = products[i];
                                    final productName = item['product']
                                            ?['product_name'] ??
                                        'Unknown';
                                    double p = double.parse(
                                            item["child_sale_price"]
                                                .toString()) *
                                        double.parse(item["child_product_qty"]
                                            .toString());

                                    String price = p.toString();

                                    return Column(
                                      children: [
                                        _buildProductRow(
                                            productName, price.toString()),
                                        if (i != products.length - 1)
                                          const Divider(
                                              height: 16, color: Colors.grey),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildProductRow(String name, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Apptext(
          text: name,
          fontWeight: FontWeight.w500,
          size: 10,
        ),
        Apptext(
          text: "₹ $price",
          color: Colors.green,
          fontWeight: FontWeight.bold,
          size: 10,
        ),
      ],
    );
  }
}
