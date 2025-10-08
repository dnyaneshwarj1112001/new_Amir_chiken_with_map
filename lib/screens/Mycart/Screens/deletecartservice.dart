import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> deleteCartItem(int productId) async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');
  print('Token: $token');

  final url = Uri.parse('https://meatzo.com/api/cart/$productId');

  try {
    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Deleted successfully: ${response.body}');
    } else {
      print('Failed to delete: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
