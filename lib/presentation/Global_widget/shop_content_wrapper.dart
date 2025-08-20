import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/bottomNavigationbar.dart';
import 'package:meatzo/screens/shop/ShopDetailsPage.dart';
import 'package:meatzo/screens/shop/productdetailstpage.dart';
import 'package:meatzo/screens/shop/allshopsgridpage.dart';
import 'package:meatzo/presentation/Global_widget/app_routes.dart';

class ShopContentWrapper extends StatelessWidget {
  final String routeType;
  final Map<String, dynamic> arguments;

  const ShopContentWrapper({
    super.key,
    required this.routeType,
    required this.arguments,
  });

  @override
  Widget build(BuildContext context) {
    // Use the original NavBar but wrap the content
    return WillPopScope(
      onWillPop: () async {
        // Navigate back to home with bottom navigation
        NavigationService.instance.goToHome(context);
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        body: _buildContent(),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildContent() {
    switch (routeType) {
      case 'shop-details':
        return ShopDetailsPage(
          text: arguments['shopName'] ?? 'Shop',
          shopId: arguments['shopId'] ?? '',
          images: arguments['images'] ?? '',
          deliveryIn: arguments['deliveryIn'] ?? 'N/A',
          closedAt: arguments['closedAt'] ?? 'N/A',
          openAt: arguments['openAt'] ?? 'N/A',
          latitude: arguments['latitude'] ?? '',
          lagitude: arguments['lagitude'] ?? '',
        );

      case 'product-details':
        return ProductDetailList(
          categoryId: arguments['categoryId'] ?? 0,
          categoryName: arguments['categoryName'] ?? 'Products',
        );

      case 'all-shops':
        return AllShopsGridPage(shops: arguments['shops'] ?? []);

      default:
        return const Center(child: Text('Page not found'));
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF9A292F),
      currentIndex: 0, // Always show home tab as active
      onTap: (index) {
        // Handle navigation to other tabs
        switch (index) {
          case 0:
            // Already on home tab (shop/product content)
            break;
          case 1:
            NavigationService.instance.goToCart(context);
            break;
          case 2:
            NavigationService.instance.goToOrder(context);
            break;
          case 3:
            NavigationService.instance.goToProfile(context);
            break;
        }
      },
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), label: "MyCart"),
        BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping), label: "Order"),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), label: "Profile"),
      ],
    );
  }
}
