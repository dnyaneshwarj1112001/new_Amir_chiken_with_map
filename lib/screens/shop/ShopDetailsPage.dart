import 'dart:convert';

import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:meatzo/screens/shop/shopwiseprodectlineerlistpage.dart';
import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';
import 'package:meatzo/presentation/Global_widget/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';
import 'package:meatzo/presentation/Global_widget/app_routes.dart';

class ShopDetailsPage extends StatefulWidget {
  final String text;
  final String shopId;
  final String images;
  final String deliveryIn;
  final String closedAt;
  final String openAt;
  final String latitude;
  final String lagitude;

  const ShopDetailsPage({
    super.key,
    required this.text,
    required this.shopId,
    required this.images,
    required this.deliveryIn,
    required this.closedAt,
    required this.openAt,
    required this.latitude,
    required this.lagitude,
  });

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  List<dynamic> productList = [];
  @override
  void initState() {
    super.initState();
    getproductdata();
  }

  Future<void> getproductdata() async {
    final baseurl = "https://meatzo.com/api/shop/details/${widget.shopId}";
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    final response = await http.get(Uri.parse(baseurl), headers: {
      'Authorization': "Bearer $token",
      'Accept': 'application/json',
    });

    // Check if widget is still mounted before calling setState
    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final productdata = data['products'];

      setState(() {
        productList = productdata;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 340,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.images),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      // Use NavigationService to go back to home with bottom navigation
                      NavigationService.instance.goToHome(context);
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Apptext(
                                text: widget.text,
                                color: Colors.white,
                                size: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              const Gaph(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.white, size: 16),
                                  const Gapw(width: 4),
                                  Apptext(
                                    text: "Opens at ${widget.openAt}",
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final latitude = widget.latitude;
                            final longitude = widget.lagitude;

                            // Get location name from coordinates
                            try {
                              List<Placemark> placemarks =
                                  await placemarkFromCoordinates(
                                      double.parse(latitude),
                                      double.parse(longitude));

                              if (placemarks.isNotEmpty) {
                                Placemark place = placemarks.first;
                                String locationName =
                                    "${place.name}, ${place.locality}, ${place.administrativeArea}";

                                final googleMapsUrl =
                                    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$locationName';

                                if (await canLaunchUrl(
                                    Uri.parse(googleMapsUrl))) {
                                  await launchUrl(Uri.parse(googleMapsUrl),
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Could not open Google Maps')),
                                  );
                                }
                              }
                            } catch (e) {
                              final googleMapsUrl =
                                  'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
                              if (await canLaunchUrl(
                                  Uri.parse(googleMapsUrl))) {
                                await launchUrl(Uri.parse(googleMapsUrl),
                                    mode: LaunchMode.externalApplication);
                              }
                            }
                          },
                          child: Chip(
                            label: const Row(
                              children: [
                                Icon(Icons.directions, color: Colors.white),
                                Apptext(
                                  text: "Directions",
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            backgroundColor: Appcolor.primaryRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Gaph(height: 10),
            const Apptext(
              text: "Our Products",
              size: 15,
              fontWeight: FontWeight.bold,
            ),
            const Gaph(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Appcolor.primaryRed.withOpacity(0.8),
                    Appcolor.primaryRed,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Appcolor.primaryRed.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Special Offer",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Get 20% OFF",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "On your first order",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.local_offer,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gaph(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 200),
              child: ShopwiseProductLinearList(
                productList: productList,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Appcolor.primaryRed, size: 20),
          const SizedBox(width: 10),
          Apptext(
            text: title,
            fontWeight: FontWeight.bold,
          ),
          Apptext(text: value),
        ],
      ),
    );
  }

  Widget ratingRow(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.star, color: Appcolor.primaryRed, size: 20),
          const SizedBox(width: 10),
          const Apptext(
            text: "Ratings:",
            fontWeight: FontWeight.bold,
          ),
          Row(
            children: List.generate(
              fullStars,
              (index) => const Icon(Icons.star, color: Colors.amber, size: 20),
            )..addAll(
                hasHalfStar
                    ? [
                        const Icon(Icons.star_half,
                            color: Colors.amber, size: 20)
                      ]
                    : [],
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Appcolor.primaryRed,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        backgroundColor: Colors.white,
        selectedColor: Appcolor.primaryRed,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? Appcolor.primaryRed : Colors.grey.shade300,
        ),
        onSelected: (bool selected) {
          setState(() {
            // Add your filter logic here
          });
        },
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
