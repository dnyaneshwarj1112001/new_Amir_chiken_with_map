
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
    const String url = '$_baseUrl/Address';

    if (token == null) {
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

          return data;
        } else {
          return null;
        }
      } else {
      
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
