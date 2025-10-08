
// mycartapiservice.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderApi {
  static const String _baseUrl = 'https://meatzo.com/api';

  static Future<List<dynamic>?> fetchOrderData(String Address) async {
    final Addressdata = Address;
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final String url = '$_baseUrl/Address';

    if (token == null) {
      print("Token not found");
      return null;
    }

    try {
      final response = await http.post(Uri.parse(url), headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: {
        Address:Address
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          print("Address Update SuccessFully");

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
