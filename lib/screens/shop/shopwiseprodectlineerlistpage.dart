import 'package:meatzo/screens/Mycart/Screens/MyCartScreen.dart';
import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/gap.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';
import 'package:meatzo/screens/Mycart/Screens/Addtocartservice.dart';
import 'package:meatzo/screens/Mycart/Screens/mycartapiservice.dart';

class ShopwiseProductLinearList extends StatefulWidget {
  final List<dynamic> productList;

  const ShopwiseProductLinearList({
    super.key,
    required this.productList,
  });

  @override
  State<ShopwiseProductLinearList> createState() =>
      _ShopwiseProductLinearListState();
}

class _ShopwiseProductLinearListState extends State<ShopwiseProductLinearList> {
  final Map<int, int> selectedSizeIndex = {};
  final String baseImageUrl = "https://meatzo.com/uploads/main_img/";
  List<dynamic> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      final items = await CartApi.fetchCartData();
      if (items != null) {
        setState(() {
          cartItems = items;
        });
      }
    } catch (e) {
    }
  }

  void showCenteredSnackBar(String message, bool isSuccess) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSuccess ? Colors.green : Colors.red,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSuccess ? Colors.green : Colors.red)
                        // ignore: deprecated_member_use
                        .withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSuccess ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess ? Icons.check : Icons.error_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: isSuccess
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.productList.isEmpty) {
      return const SizedBox(
        height: 280,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                "No Products Found",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack( 
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: widget.productList.length,
                itemBuilder: (context, index) {
                  final product = widget.productList[index];
                  final List prices = product['prices'] ?? [];
                  final productId =
                      product['tbl_product_id'] ?? product['product_id'];
                  final shopId = product['shop'];

                  if (prices.isEmpty) return const SizedBox();

                  selectedSizeIndex.putIfAbsent(index, () => 0);
                  final selectedPrice = prices[selectedSizeIndex[index]!];

                  final imageUrl = product['main_img'];
                  final completeUrl = '$baseImageUrl$imageUrl';

                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: SizedBox(
                            height: 110,
                            width: double.infinity,
                            child: Image.network(
                              completeUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image,
                                    size: 40, color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          child: Text(
                            product['product_name'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 40, left: 50),
                          child: IntrinsicWidth(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedSizeIndex[index],
                                isExpanded: false,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black),
                                onChanged: (int? newIndex) {
                                  setState(() {
                                    selectedSizeIndex[index] = newIndex!;
                                  });
                                },
                                items: List.generate(
                                  prices.length,
                                  (i) => DropdownMenuItem<int>(
                                    value: i,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(prices[i]['size']),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.currency_rupee,
                                  size: 14, color: Colors.green),
                              Row(
                                children: [
                                  Text(
                                    "${selectedPrice['sale_price']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Gapw(width: 20),
                                  if (selectedPrice['paper_price'] !=
                                      selectedPrice['sale_price'])
                                    Text(
                                      "₹${selectedPrice['paper_price']}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          child: Row(
                            children: [
                              const SizedBox(width: 4),
                              if (selectedPrice['discount_percentage'] != "0.00")
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.local_offer,
                                          size: 12, color: Colors.white),
                                      const SizedBox(width: 2),
                                      Text(
                                        "${selectedPrice['discount_percentage']}% OFF",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () async {
                            final priceId = selectedPrice['price_id'];

                            final result = await CartService.addToCartHttp(
                              productId: productId.toString(),
                              priceId: priceId.toString(),
                              shopId: shopId.toString(),
                            );
 
                            showCenteredSnackBar(
                                result['message'], true 
                                );

                            
                            fetchCartItems();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Appcolor.primaryRed,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_shopping_cart,
                                    size: 18, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  "Add to Cart",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey.shade300,
                            Appcolor.primaryRed.withOpacity(0.5),
                            Colors.grey.shade300,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (cartItems.isNotEmpty) 
          Positioned(
            top: 10, 
            right: -15,  
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyCardScreen()),
                );
                fetchCartItems();
              },
              icon: const Icon(Icons.shopping_cart, color: Colors.redAccent),
              label: Text(
                'Cart (${cartItems.length})',
                style: const TextStyle(color: Colors.redAccent),
              ),
              style: ElevatedButton.styleFrom(
              
                elevation: 5,
                backgroundColor: const Color.fromARGB(255, 255, 247, 247),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
