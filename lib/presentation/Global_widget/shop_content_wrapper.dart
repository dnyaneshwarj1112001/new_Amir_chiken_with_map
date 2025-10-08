import 'package:flutter/material.dart';
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
    return WillPopScope(
      onWillPop: () async {
        // Navigate back to home with bottom navigation
        Navigator.pushReplacementNamed(context, AppRoutes.home);
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
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, AppRoutes.home);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, AppRoutes.myCard);
            break;
          case 2:
            Navigator.pushReplacementNamed(context, AppRoutes.order);
            break;
          case 3:
            Navigator.pushReplacementNamed(context, AppRoutes.profile);
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
