import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';
import 'package:meatzo/services/shop_service.dart';
import 'package:flutter/material.dart';
import 'package:meatzo/screens/shop/ShopDetailsPage.dart'; // Import ShopDetailsPage

class ProductDetailList extends StatefulWidget {
  const ProductDetailList({
    super.key,
    required this.categoryId, // Add categoryId to fetch shops
    required this.categoryName, // Add category name for app bar title
  });

  final int categoryId;
  final String categoryName;

  @override
  State<ProductDetailList> createState() => _ProductDetailListState();
}

class _ProductDetailListState extends State<ProductDetailList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<dynamic> _shops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final shopService = ShopService();
      final fetchedShops =
          await shopService.fetchShopsByCategory(widget.categoryId);
      if (mounted) {
        setState(() {
          _shops = fetchedShops;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Navigates to the ShopDetailsPage, passing all necessary shop information.
  /// This method replaces the old _showWorkInProgressDialog.
  void _navigateToShopDetails(Map<String, dynamic> shop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopDetailsPage(
          text: shop['name'] ?? 'Unknown', // Shop name for display
          shopId: shop['id']?.toString() ?? '', // Shop ID, converted to string
          images: shop['image'] ?? '', // Shop image URL
          deliveryIn: shop['delivery_time'] ?? 'N/A', // Assuming a 'delivery_time' field exists, otherwise use a default
          closedAt: shop['closes_at'] ?? 'N/A', // Shop closing time
          openAt: shop['opens_at'] ?? 'N/A', // Shop opening time
          latitude: shop['lat']?.toString() ?? '', // Shop latitude
          lagitude: shop['lng']?.toString() ?? '', // Shop longitude
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        title: widget.categoryName, // Use category name for title
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Appcolor.primaryRed),
            )
          : _shops.isEmpty
              ? const Center(child: Text("No shops available for this category."))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FadeTransition(
                    opacity: _animation,
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _shops.length,
                      itemBuilder: (context, index) {
                        final shop = _shops[index];
                        return AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _animation.value,
                              child: child,
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shadowColor: Colors.black45,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              // Changed onTap to navigate to ShopDetailsPage
                              onTap: () => _navigateToShopDetails(shop),
                              splashColor: Appcolor.primaryRed.withOpacity(0.2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Image.network( // Use Image.network for shop image
                                      shop['image'] ?? 'https://via.placeholder.com/150', // Placeholder if image is null
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      shop['name'] ?? 'Unknown Shop',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
