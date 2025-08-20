import 'dart:convert';
import 'package:meatzo/screens/Mycart/Screens/Addtocartservice.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Ensure these imports are correct and available in your project
// import 'package:connectivity_plus/connectivity_plus.dart'; // If you're using this
import 'package:meatzo/helper/util.dart';

import 'package:meatzo/presentation/Global_widget/Appcolor.dart';
import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:meatzo/presentation/Global_widget/gap.dart';
// Your updated Categories widget

import 'package:meatzo/screens/Screen/HomeScrens/pincodepopup.dart';
import 'package:meatzo/screens/Screen/HomeScrens/pin_Code_service.dart';
import 'package:meatzo/screens/shop/allshopsgridpage.dart'; // Ensure this file exists
import 'package:meatzo/screens/Screen/HomeScrens/near_shops.dart';
import 'package:meatzo/screens/Screen/HomeScrens/shopsListHorizontal.dart';
import 'package:meatzo/screens/Mycart/Screens/mycartapiservice.dart';
import 'package:meatzo/presentation/Global_widget/app_routes.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  List<dynamic> BannerList = [];
  List<dynamic> categories = []; // This will hold your fetched categories
  List<dynamic> shoplist = [];
  String? SelectedPincode;
  bool isLoding = true;

  String? _lastConfirmedPincode;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _checkAndShowPincode();

    final prefs = await SharedPreferences.getInstance();
    _lastConfirmedPincode = prefs.getString('selected_pincode');
    await gethomepageData();
  }

  Future<void> gethomepageData() async {
    if (!mounted) return;

    try {
      const baseurl = "https://meatzo.com/api/home";
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      final response = await http.get(Uri.parse(baseurl), headers: {
        'Authorization': "Bearer $token",
        'Accept': 'application/json',
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final banners = data['banners'];
        final Categoriesdata = data["categories"]; // Correctly get categories
        final shoplistdata = data['shops']['data'];
        Util.pretty(shoplistdata); // Assuming Util.pretty is for logging
        setState(() {
          BannerList = banners;
          categories = Categoriesdata; // Set the categories list
          shoplist = shoplistdata;
          isLoding = false;
        });
      } else {
        if (mounted) {
          setState(() {
            isLoding = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoding = false;
        });
      }
    }
  }

  Future<void> _checkAndShowPincode() async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPincode = prefs.getString('selected_pincode');

      if (savedPincode == null || savedPincode.isEmpty) {
        if (mounted) {
          _showPincodeBottomSheet(true);
        }
      } else {
        if (mounted) {
          setState(() {
            SelectedPincode = savedPincode;
          });
        }
      }
    } catch (e) {}
  }

  void _showPincodeBottomSheet([bool isInitialLoad = false]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return PincodeBottomSheet(
          context,
          onLocationSelected: (String newPincode) async {
            final prefs = await SharedPreferences.getInstance();
            final String? oldPincode = SelectedPincode;

            if (!isInitialLoad &&
                oldPincode != null &&
                oldPincode != newPincode) {
              await _promptAndClearCart(oldPincode, newPincode, prefs);
            }

            await prefs.setString('selected_pincode', newPincode);
            if (mounted) {
              setState(() {
                SelectedPincode = newPincode;
                _lastConfirmedPincode = newPincode;
                isLoding = false;
              });
              pincodeprovide(newPincode);
            }
          },
        );
      },
    );
  }

  Future<void> _promptAndClearCart(
      String oldPincode, String newPincode, SharedPreferences prefs) async {
    List<dynamic> currentCartItems = await CartApi.fetchCartData() ?? [];

    if (!mounted) return;

    if (currentCartItems.isNotEmpty) {
      bool? confirmClear = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Pincode Changed'),
            content: Text(
                'Your delivery pincode has changed from $oldPincode to $newPincode. Your current cart items might not be deliverable to the new pincode. Do you want to clear your cart?'),
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
        await _clearCartOnPincodeChange(prefs);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your cart has been cleared due to pincode change.'),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Cart not cleared. Some items may not be deliverable to the new pincode.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _clearCartOnPincodeChange(SharedPreferences prefs) async {
    final result = await CartService.clearFullCartHttp();
    if (!mounted) return;
    await prefs.remove('persisted_pincode_for_cart');
  }

  void pincodeprovide(String pincode) async {
    try {
      final service = PincodeService();
      final result = await service.updatePincode(pincode);
      if (result != null && mounted) {
        setState(() {
          SelectedPincode = pincode;
        });
        await gethomepageData(); // Re-fetch data after pincode change
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(" $result"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Appcolor.primaryRed,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Apptext(
              text: "Home",
              color: Colors.white,
              size: 20,
            ),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _showPincodeBottomSheet,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        SelectedPincode ?? "Select Pincode",
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoding
          ? Center(
              child: CircularProgressIndicator(
                color: Appcolor.primaryRed,
              ),
            )
          : RefreshIndicator(
              onRefresh: _initializeData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    if (BannerList.isNotEmpty)
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 220.0,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.9,
                          aspectRatio: 16 / 9,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 800),
                        ),
                        items: BannerList.map((banner) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    banner['image'] ?? '',
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                          child: Text("Image not found"));
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "WHAT'S ON YOUR MIND?",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Pass the fetched categories to the Categories widget
                    Categories(categories: categories),
                    const Gaph(height: 10),
                    if (shoplist.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          children: [
                            const Image(
                              image: AssetImage(
                                  "lib/innitiel_screens/images/Murga.png"),
                              height: 50,
                              width: 50,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "We Deliver Fresh & Hygenic Meat From Your Favourite Shops",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      // Use the new navigation service to show bottom navigation bar
                                      NavigationService.instance.goToAllShops(
                                        context,
                                        shops: shoplist,
                                      );
                                    },
                                    child: Text(
                                      "See all",
                                      style: TextStyle(
                                        color: Appcolor.primaryRed,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ShopsNearyou(shops: shoplist),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: "cart",
            onPressed: () => NavigationService.instance.goToCart(context),
            backgroundColor: Colors.orange,
            child: const Icon(Icons.shopping_cart, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: "order",
            onPressed: () => NavigationService.instance.goToOrder(context),
            backgroundColor: Colors.green,
            child: const Icon(Icons.local_shipping, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: "profile",
            onPressed: () => NavigationService.instance.goToProfile(context),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(height: 8),
          // Demo button for shop navigation
          FloatingActionButton.small(
            heroTag: "shop_demo",
            onPressed: () => NavigationService.instance.goToShopDetails(
              context,
              shopId: "123",
              shopName: "Demo Shop",
              images: "https://via.placeholder.com/300x200",
              deliveryIn: "30-40 mins",
              closedAt: "10:00 PM",
              openAt: "8:00 AM",
              latitude: "28.6139",
              lagitude: "77.2090",
            ),
            backgroundColor: Colors.purple,
            child: const Icon(Icons.store, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
