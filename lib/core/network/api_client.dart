import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:meatzo/data/models/authresponcemodel/auth_response_model.dart';
import 'package:meatzo/data/models/authresponcemodel/verify_Otp_ResponseModel.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST("/login")
  Future<AuthResponseModel> login(@Body() Map<String, dynamic> body);

  @POST("/verify-otp")
  Future<VerifyOtpResponse> verifyOtp(@Body() Map<String, dynamic> body);
}
