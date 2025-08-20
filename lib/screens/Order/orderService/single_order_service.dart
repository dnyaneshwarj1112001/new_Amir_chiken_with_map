
import 'dart:convert';
import 'package:meatzo/presentation/Global_widget/token_manager.dart';
import 'package:http/http.dart' as http;

class SingleOrderService {
  final String baseUrl = "https://meatzo.com/api/single/order";

  Future<Map<String, dynamic>> fetchOrder(int orderId) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (!data['hasError']) {
        return data['order'];
      } else {
        throw Exception('API error: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load order: ${response.statusCode}');
    }
  }
}