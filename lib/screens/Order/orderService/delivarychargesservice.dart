import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryCharges {
  static const String _baseUrl = 'https://meatzo.com/api';

  static Future<Map<String, dynamic>?> charges() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    const String url = '$_baseUrl/delivery/charges';

    if (token == null) {
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
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
