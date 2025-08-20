import 'dart:convert';
import 'package:meatzo/data/homemodels/bannermodel.dart';
import 'package:http/http.dart' as http;

class BannerService {
  static const String baseUrl = 'https://meatzo.com/api/';
  static const String imageBaseUrl =
      'https://meatzo.com/storage/slider_images/';

  static Future<List<BannerModel>> fetchBanners() async {
    final response = await http.get(Uri.parse('${baseUrl}home'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List banners = data['banners'];
      return banners.map((e) => BannerModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load banners');
    }
  }
}
