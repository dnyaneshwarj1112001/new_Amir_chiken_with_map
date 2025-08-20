import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PincodeService {
  Future<String?> updatePincode(String pincode) async {
    final url = Uri.parse('https://meatzo.com/api/update/pincodes');

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) {
        return 'Auth token not found';
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'pincode': pincode,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['hasError'] == false) {
          return responseData['message'];
        } else {
          return "Error: ${responseData['message']}";
        }
      } else {
        return 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }
}
