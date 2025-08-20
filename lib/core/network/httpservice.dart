// lib/network/http_client.dart
import 'dart:convert';
import 'package:meatzo/presentation/Global_widget/baseurl.dart';
import 'package:meatzo/presentation/Global_widget/token_manager.dart';
import 'package:http/http.dart' as http;

class HttpClient {
  static Future<http.Response> get(String endpoint) async {
    final token = await TokenManager.getToken();
    final url = Uri.parse('${baseurl.baseUrl}$endpoint');

    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> body) async {
    final token = await TokenManager.getToken();
    final url = Uri.parse('${baseurl.baseUrl}$endpoint');

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(
      String endpoint, Map<String, dynamic> body) async {
    final token = await TokenManager.getToken();
    final url = Uri.parse('${baseurl.baseUrl}$endpoint');

    return await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final token = await TokenManager.getToken();
    final url = Uri.parse('${baseurl.baseUrl}$endpoint');

    return await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
}
