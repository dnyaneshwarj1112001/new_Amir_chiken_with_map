// mycartapiservice.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartApi {
  static const String _baseUrl = 'https://meatzo.com/api';

  static Future<List<dynamic>?> fetchCartData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final String url = '$_baseUrl/cart';

    if (token == null) {
      print("Token not found");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          print(data);
          return data;
        } else {
          print("Unexpected response format");
          return null;
        }
      } else {
        print("Failed to fetch cart: ${response.statusCode}");
        print(response.body);
        return null;
      }
    } catch (e) {
      print("Error fetching cart: $e");
      return null;
    }
  }
}
