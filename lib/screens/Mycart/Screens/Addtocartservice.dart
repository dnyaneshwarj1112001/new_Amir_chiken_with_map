import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _baseUrl = 'https://meatzo.com/api';

  static Future<Map<String, dynamic>> addToCartHttp({
    required String productId,
    required String priceId,
    required String shopId,
    int quantity = 1,
  }) async {
    const String url = '$_baseUrl/cart';
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_id': productId,
          'price_id': priceId,
          "cart_shop_id": shopId,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Added to cart successfully'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to add to cart'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong. Please try again later.'
      };
    }
  }

  static Future<Map<String, dynamic>> deleteCartItemHttp({
    required String productId,
  }) async {
    final String url = '$_baseUrl/cart/$productId';
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cart item deleted successfully'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete cart item'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong. Please try again later.'
      };
    }
  }

  static Future<Map<String, dynamic>> clearFullCartHttp() async {
    const String url = '$_baseUrl/cart';
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cart cleared successfully'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to clear cart'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong during cart clearing: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> updateQty(
      {required String cartId, required int qty}) async {
    final String url = '$_baseUrl/cart/$cartId';
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    try {
      final response = await http.put(Uri.parse(url), headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: {
        "productQty": qty.toString(),
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              data['message'] ?? 'Cart item quantity updated successfully'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update cart item quantity'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong. Please try again later.'
      };
    }
  }
}
