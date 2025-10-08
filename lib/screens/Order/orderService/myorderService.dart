import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailq {
  static const String _baseUrl = 'https://meatzo.com/api';

  static Future<List<dynamic>?> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final String url = '$_baseUrl/orders/list';

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
      
        if (data['orders'] is List) {
          print("Orders fetched successfully");
          return data['orders'];
        } else {
          print("Unexpected orders format");
          return null;
        }
      } else {
        print("Failed to fetch orders: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching orders: $e");
      return null;
    }
  }
}
