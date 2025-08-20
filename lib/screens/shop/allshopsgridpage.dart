// lib/screens/shop/allshopsgridpage.dart
import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';
import 'package:meatzo/presentation/Global_widget/apptext.dart'; // Assuming you use Apptext here
import 'package:meatzo/presentation/Global_widget/emtydata.dart'; // Import EmptyStateWidget
import 'package:meatzo/presentation/Global_widget/app_routes.dart';

class AllShopsGridPage extends StatefulWidget {
  final List<dynamic> shops; // This will now hold your fetched real shop data

  // Removed dummy data parameters like 'pincode', 'text', 'images', 'subtitle', 'time'
  const AllShopsGridPage({
    super.key,
    required this.shops,
  });

  @override
  State<AllShopsGridPage> createState() => _AllShopsGridPageState();
}

class _AllShopsGridPageState extends State<AllShopsGridPage> {
  /// Navigates to the ShopDetailsPage, passing all necessary shop information.
  void navigateToDetails(Map<String, dynamic> shop) {
    AppRoutes.navigateToShopDetails(
      context,
      shopId: shop['id']?.toString() ?? '',
      shopName: shop['name'] ?? 'Unknown',
      images: shop['image'] ?? '',
      deliveryIn: shop['delivery_time'] ?? 'N/A',
      closedAt: shop['closes_at'] ?? 'N/A',
      openAt: shop['opens_at'] ?? 'N/A',
      latitude: shop['lat'] ?? '',
      lagitude: shop['lng'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shops.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Appcolor.primaryRed,
          title: const Text('All Shops', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => NavigationService.instance.goToHome(context),
          ),
        ),
        body: const EmptyStateWidget(
          message: "No shops available.",
          icon: Icons.store_mall_directory,
          height: 240, // You might adjust this height
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Appcolor.primaryRed,
        title: const Text('All Shops', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationService.instance.goToHome(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns for the shop grid
            crossAxisSpacing: 12, // Horizontal spacing
            mainAxisSpacing: 12, // Vertical spacing
            childAspectRatio: 0.75, // Aspect ratio for each grid item
          ),
          itemCount: widget.shops.length,
          itemBuilder: (context, index) {
            final shop = widget.shops[index]; // Get the current shop data
            final shopId = shop['id']?.toString() ?? '';
            final shopName = shop['name'] ?? 'Unknown';
            final shopImage = shop['image'] ?? '';
            final opensAt = shop['opens_at'] ?? 'N/A';
            final pincode = shop['pincode']?.toString() ?? 'N/A';
            // Assuming 'delivery_time' or similar field for estimated delivery
            final deliveryTime = shop['delivery_time'] ?? '30-40 Mins';

            if (shopId.isEmpty || shopName == 'Unknown') {
              return const SizedBox.shrink(); // Hide invalid shop entries
            }

            return Card(
              elevation: 5,
              shadowColor: Colors.black45,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () =>
                    navigateToDetails(shop), // Tap to open shop details
                splashColor: Appcolor.primaryRed.withOpacity(0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Image.network(
                        shopImage.isNotEmpty
                            ? shopImage
                            : '[https://via.placeholder.com/150](https://via.placeholder.com/150)', // Use shop image, with fallback
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Apptext(
                              text: shopName,
                              fontWeight: FontWeight.bold,
                              size: 14),
                          const SizedBox(height: 4),
                          Text(
                            "Opens: $opensAt",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: Colors.red),
                              Text(
                                pincode,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Delivery in: $deliveryTime",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 40, // Increased height for better tap area
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Appcolor.primaryRed,
                        borderRadius: const BorderRadius.only(
                          bottomLeft:
                              Radius.circular(16), // Match card border radius
                          bottomRight:
                              Radius.circular(16), // Match card border radius
                        ),
                      ),
                      child: InkWell(
                        onTap: () =>
                            navigateToDetails(shop), // Tap to open shop details
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Shop Now",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.shopping_cart,
                                color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
