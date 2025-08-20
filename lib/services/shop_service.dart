// lib/services/shop_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ShopService {
  static const String _baseUrl = "https://meatzo.com/api";

  /// Fetches a list of shops belonging to a specific category.
  /// Requires an authentication token from SharedPreferences.
  Future<List<dynamic>> fetchShopsByCategory(int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    final url = Uri.parse("$_baseUrl/shop/by/category/$categoryId");
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': "Bearer $token",
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check for 'hasError' flag and 'shops' data existence in the API response
        if (data['hasError'] == false && data['shops'] != null) {
          return data['shops']['data']; // Return the list of shop data
        } else {
          return []; // Return empty list on API-level error
        }
      } else {
        return []; // Return empty list on HTTP error
      }
    } catch (e) {
      return []; // Return empty list on network/parsing error
    }
  }
}
