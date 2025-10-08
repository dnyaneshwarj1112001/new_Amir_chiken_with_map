// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class PlaceOrderService {
//   static Future<Map<String, dynamic>> placeOrder({
//     required String paymentMode,
//     String? razorpayPaymentId,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString("auth_token");

//       final baseUrl = "https://meatzo.com/api/order";

//       final Map<String, dynamic> body = {
//         "payment_mode": paymentMode,
//       };

//       // Add razorpay payment ID only if payment mode is online
//       if (paymentMode == "online" && razorpayPaymentId != null) {
//         body["razorpay_payment_id"] = razorpayPaymentId;
//       }

//       final response = await http.post(
//         Uri.parse(baseUrl),
//         headers: {
//           'Authorization': "Bearer $token",
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(body),
//       );
//       print("response ${response.body}");

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print("response ${response.body}");

//         return response.body;
//       } else {
//         final errorData = jsonDecode(response.body);
//         return {
//           'success': false,
//           'message': errorData['message'] ?? 'S545454554455555',
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Error placing order: $e',
//       };
//     }
//   }
// }
