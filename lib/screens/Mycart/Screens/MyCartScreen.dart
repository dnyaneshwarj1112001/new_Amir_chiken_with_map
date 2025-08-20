import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';
import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:meatzo/screens/Mycart/Screens/Addtocartservice.dart';
import 'package:meatzo/screens/Mycart/AddressList.dart';
import 'package:meatzo/screens/Order/orderService/delivarychargesservice.dart';
import 'package:meatzo/screens/Mycart/Screens/mycardhelper.dart';
import 'package:meatzo/screens/Mycart/Screens/mycartapiservice.dart';
import 'package:meatzo/screens/Order/OrderRecipt1.dart';
import 'package:meatzo/presentation/Global_widget/app_routes.dart';
import 'package:meatzo/presentation/Global_widget/mycardtext.dart';
import 'package:hive/hive.dart';

class MyCardScreen extends StatefulWidget {
  const MyCardScreen({super.key});

  @override
  State<MyCardScreen> createState() => _MyCardScreenState();
}

class _MyCardScreenState extends State<MyCardScreen>
    with TickerProviderStateMixin {
  List<dynamic> cartList = [];
  List<int> quantities = [];
  double subtotal = 0.0;
  double totalDiscount = 0.0;
  double totalGst = 0.0;
  int deliveryCharges = 0;
  Map<String, String>? savedAddress;
  String address = "";
  String mobile = "";
  String shippingPincode = "";
  String? selectedPincodeFromHome;

  bool showPincodeMismatchWarning = false;
  bool _isDataLoading = true;

  String? _persistedPincodeForCart;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    setState(() {
      _isDataLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();

    selectedPincodeFromHome = prefs.getString('selected_pincode');

    _persistedPincodeForCart = prefs.getString('persisted_pincode_for_cart');

    if (_persistedPincodeForCart != null &&
        selectedPincodeFromHome != null &&
        _persistedPincodeForCart != selectedPincodeFromHome) {
      bool? confirmClear = await showDialog<bool>(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Pincode Changed'),
            content: Text(
                'Your delivery pincode has changed from $_persistedPincodeForCart to $selectedPincodeFromHome. Your current cart items might not be deliverable to the new pincode. Do you want to clear your cart?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('No', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Yes, Clear Cart',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      if (confirmClear == true) {
        await _clearCartAndNotify();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Cart not cleared. Some items may not be deliverable to the new pincode.'),
            duration: Duration(seconds: 5),
          ),
        );
        await loadCartData();
      }
    } else {
      await loadCartData();
    }

    await fetchDeliveryCharges();
    await _loadSavedAddress();
    _checkPincodeMismatch();

    if (selectedPincodeFromHome != null) {
      await prefs.setString(
          'persisted_pincode_for_cart', selectedPincodeFromHome!);
    } else {
      await prefs.remove('persisted_pincode_for_cart');
    }

    if (mounted) {
      setState(() {
        _isDataLoading = false;
      });
    }
  }

  Future<void> _clearCartAndNotify() async {
    if (!mounted) return;
    if (mounted) {
      setState(() {
        cartList.clear();
        quantities.clear();
        subtotal = 0.0;
        totalDiscount = 0.0;
        totalGst = 0.0;
        deliveryCharges = 0;
        showPincodeMismatchWarning = false;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your cart has been cleared due to pincode change.'),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _checkPincodeMismatch() {
    if (!mounted) return;

    if (selectedPincodeFromHome != null &&
        selectedPincodeFromHome!.isNotEmpty &&
        shippingPincode.isNotEmpty &&
        selectedPincodeFromHome != shippingPincode) {
      setState(() {
        showPincodeMismatchWarning = true;
      });
    } else {
      setState(() {
        showPincodeMismatchWarning = false;
      });
    }
  }

  Future<void> loadCartData() async {
    final items = await CartApi.fetchCartData();
    if (mounted) {
      cartList = items ?? [];
      if (cartList.isEmpty) {
        quantities = [];
        deliveryCharges = 0;
      } else {
        quantities = List.generate(cartList.length, (index) {
          return int.tryParse(cartList[index]['quantity']?.toString() ?? '1') ??
              1;
        });
      }
      _calculateAllTotals();
    }
  }

  void _calculateAllTotals() {
    double tempSubtotal = 0.0;
    double tempTotalDiscount = 0.0;
    double tempTotalGst = 0.0;

    for (int i = 0; i < cartList.length; i++) {
      final item = cartList[i];
      final priceStr = item['price']?['sale_price']?.toString() ?? '0';
      final price = double.tryParse(priceStr) ?? 0.0;
      final currentQuantity = quantities[i];

      tempSubtotal += price * currentQuantity;

      final discountPercent = double.tryParse(
              item['price']?['discount_percentage']?.toString() ?? '0.0') ??
          0.0;
      final discount = (price * discountPercent) / 100;
      tempTotalDiscount += discount * currentQuantity;

      final taxPercent = double.tryParse(
              item['price']?['tax_percentage']?.toString() ?? '0.0') ??
          0.0;
      final gst = (price * taxPercent) / 100;
      tempTotalGst += gst * currentQuantity;
    }

    subtotal = tempSubtotal;
    totalDiscount = tempTotalDiscount;
    totalGst = tempTotalGst;
  }

  void increaseQuantity(int index, String cartId) {
    setState(() {
      quantities[index]++;
      CartService.updateQty(cartId: cartId.toString(), qty: quantities[index]);
      _calculateAllTotals();
      _checkPincodeMismatch();
    });
  }

  void decreaseQuantity(int index, String cartId) {
    if (quantities[index] > 1) {
      setState(() {
        quantities[index]--;
        CartService.updateQty(
            cartId: cartId.toString(), qty: quantities[index]);
        _calculateAllTotals();
        _checkPincodeMismatch();
      });
    }
  }

  void deleteItem(String id) async {
    final result =
        await CartService.deleteCartItemHttp(productId: id.toString());

    if (mounted && result['success']) {
      await loadCartData();
      _checkPincodeMismatch();
      setState(() {});
    }
  }

  Future<void> fetchDeliveryCharges() async {
    final data = await DeliveryCharges.charges();

    if (mounted) {
      if (data != null && data['status'] == true) {
        final double deliveryCharge = double.tryParse(
              data['delivery_charges']?.toString() ?? '0.0',
            ) ??
            0.0;

        final double distance = double.tryParse(
              data['distance_km']?.toString() ?? '0.0',
            ) ??
            0.0;

        final int amt = (distance * 10).toInt();
        deliveryCharges = amt;
      } else {
        deliveryCharges = 0;
      }
    }
  }

  Future<void> _loadSavedAddress() async {
    final box = await Hive.openBox('addressBox');
    if (mounted) {
      final pinFromBox = box.get('pin', defaultValue: '411032');
      address =
          "${box.get('city', defaultValue: 'Pune')}, ${box.get('state', defaultValue: 'Maharashtra')}, $pinFromBox";
      mobile = "${box.get('mobile', defaultValue: '+91 7028996365')}";
      shippingPincode = pinFromBox.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canProceed =
        !_isDataLoading && cartList.isNotEmpty && !showPincodeMismatchWarning;
    double finalTotal = canProceed
        ? subtotal - totalDiscount + deliveryCharges + totalGst
        : 0.0;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, AppRoutes.nav);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: const CustomAppBar(
          title: "My Cart",
          titleColor: Colors.white,
          titleFontWeight: FontWeight.bold,
        ),
        body: Column(
          children: [
            Expanded(
              child: _isDataLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Appcolor.primaryRed,
                      ),
                    )
                  : cartList.isEmpty
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
                                text: "No Cart Found",
                                size: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: cartList.length,
                          itemBuilder: (context, index) {
                            final item = cartList[index];
                            final cartId = item['cart_id'];
                            final name =
                                item['product']?['product_name'] ?? 'Product';
                            final priceStr =
                                item['price']?['sale_price']?.toString() ??
                                    '0.00';
                            final price = double.tryParse(priceStr) ?? 0.0;
                            final image = "https://meatzo.com/" +
                                item['product']['main_img'];

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        image,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        cardtext(
                                          leadingtext: "Price:",
                                          trailingtext: "Rs. $priceStr",
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              constraints:
                                                  const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                              onPressed: () => decreaseQuantity(
                                                  index, cartId),
                                              icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade400),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                  "${quantities[index]} x ${price.toInt()}"),
                                            ),
                                            IconButton(
                                              onPressed: () => increaseQuantity(
                                                  index, cartId),
                                              icon: const Icon(Icons.add_circle,
                                                  color: Colors.green),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              onPressed: () =>
                                                  deleteItem(cartId),
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Mycardhelper(
                    lable: "Sub Total",
                    amount: subtotal.toStringAsFixed(2),
                    amountColor: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  const Divider(),
                  Mycardhelper(
                    lable: "Discount",
                    amount: totalDiscount.toStringAsFixed(2),
                    amountColor: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  const Divider(),
                  Mycardhelper(
                    lable: "Delivery Charge",
                    amount: deliveryCharges.toString(),
                    amountColor: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  const Divider(),
                  Mycardhelper(
                    lable: "GST",
                    amount: totalGst.toStringAsFixed(2),
                    amountColor: Appcolor.primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                  const Divider(),
                  Mycardhelper(
                    lable: "Total",
                    amount: finalTotal.toStringAsFixed(2),
                    amountColor: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Apptext(
                              text: "Shipping Address",
                              size: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddressList(),
                                  ),
                                );

                                if (mounted && result != null) {
                                  setState(() {
                                    address =
                                        "${result.city}, ${result.state}, ${result.pinCode}";
                                    mobile =
                                        "${result.countryCode ?? "+91"} ${result.mobileNumber}";
                                    shippingPincode = result.pinCode.toString();
                                  });
                                  _checkPincodeMismatch();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white, // white background
                                  borderRadius:
                                      BorderRadius.circular(30), // pill-shaped
                                  border: Border.all(
                                      color: Colors.red,
                                      width: 1), // optional border
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: const Text(
                                  "Change",
                                  style: TextStyle(
                                    color: Colors.red, // red text
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Apptext(
                          text: "$address\nPhone: $mobile",
                        ),
                        if (showPincodeMismatchWarning) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Text(
                              "Your selected delivery pincode ($selectedPincodeFromHome) does not match the shipping address pincode ($shippingPincode). Please change your delivery location or shipping address.",
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),

                              maxLines: null, // allow multi-line
                              overflow: TextOverflow
                                  .visible, // text wraps instead of clipping
                              textAlign: TextAlign.start, // better alignment
                            ),
                          )
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isDataLoading || !canProceed
                        ? null
                        : () {
                            String combinedProductNames = cartList.map((item) {
                              return item['product']?['product_name'] ??
                                  'Product';
                            }).join(', ');

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderRecipt(
                                  productName: combinedProductNames,
                                  price: subtotal,
                                  discount: totalDiscount,
                                  tax: totalGst,
                                  address: address,
                                  mobile: mobile,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_isDataLoading || !canProceed)
                          ? Colors.grey
                          : Colors.red,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Continue to Payment",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
