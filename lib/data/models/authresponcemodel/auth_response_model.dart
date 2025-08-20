import 'package:json_annotation/json_annotation.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final String? message;
  final int? otp;
  final bool hasError;

  AuthResponseModel({
    this.message,
    this.otp,
    required this.hasError,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
