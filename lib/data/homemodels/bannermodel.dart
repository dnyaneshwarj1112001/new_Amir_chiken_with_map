// lib/data/homemodels/banner_model.dart

class BannerModel {
  final int sliderId;
  final String sliderName;
  final String? sliderImg;  // Make this nullable

  BannerModel({
    required this.sliderId,
    required this.sliderName,
    required this.sliderImg,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      sliderId: json['slider_id'],
      sliderName: json['slider_name'],
      sliderImg: json['slider_img'],  // This can now be null
    );
  }
}
