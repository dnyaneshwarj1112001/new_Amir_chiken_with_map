import 'package:meatzo/presentation/Global_widget/emtydata.dart';
import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';
import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:meatzo/screens/shop/ShopDetailsPage.dart';

class ShopsNearyou extends StatefulWidget {
  final List<dynamic> shops;
  final String time;
  final int pincode;

  const ShopsNearyou({
    super.key,
    required this.shops,
    this.time = "30-40 Mins",
    this.pincode = 415524,
  });

  @override
  State<ShopsNearyou> createState() => _ShopsNearyouState();
}

class _ShopsNearyouState extends State<ShopsNearyou> {
  void navigateToDetails(Map<String, dynamic> shop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopDetailsPage(
          text: shop['name'] ?? 'Unknown',
          shopId: shop['id']?.toString() ?? '',
          images: shop['image'] ?? '',
          deliveryIn: shop['opens_at'] ?? 'N/A',
          closedAt: shop['closes_at'] ?? 'N/A',
          openAt: shop['opens_at'] ?? 'N/A',
          latitude: shop['lat'] ?? '',
          lagitude: shop['lng'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shops.isEmpty) {
      return const EmptyStateWidget(
        message: "No shops found near you",
        icon: Icons.store_mall_directory,
        height: 240,
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 10),
        itemExtent: 160,
        itemCount: widget.shops.length,
        itemBuilder: (context, index) {
          final shop = widget.shops[index];
          final shopId = shop['id']?.toString() ?? '';
          final shopName = shop['name'] ?? 'Unknown';
          final shopImage = shop['image'] ?? '';
          final opensAt = shop['opens_at'] ?? 'N/A';
          final pincode = shop['pincode']?.toString() ?? 'N/A';

          if (shopId.isEmpty || shopName == 'Unknown') {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => navigateToDetails(shop),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.5,
                        child: shopImage.isNotEmpty
                            ? Image.network(
                                shopImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Apptext(
                            text: shopName,
                            fontWeight: FontWeight.bold,
                            size: 12,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Apptext(
                                text: "Opens At: ",
                                fontWeight: FontWeight.bold,
                                size: 12,
                              ),
                              Apptext(
                                text: opensAt,
                                size: 10,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: Colors.red),
                              Text(
                                " $pincode",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 36,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Appcolor.primaryRed,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: InkWell(
                        onTap: () => navigateToDetails(shop),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Shop Now",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.shopping_cart, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
