// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      message: json['message'] as String?,
      otp: (json['otp'] as num?)?.toInt(),
      hasError: json['hasError'] as bool,
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'message': instance.message,
      'otp': instance.otp,
      'hasError': instance.hasError,
    };
