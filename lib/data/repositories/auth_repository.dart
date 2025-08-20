import 'package:meatzo/core/network/api_client.dart';
import 'package:meatzo/data/models/authresponcemodel/auth_response_model.dart';
import 'package:meatzo/data/models/authresponcemodel/verify_Otp_ResponseModel.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<AuthResponseModel> login(String phoneNumber) {
    return apiClient.login({"mobile_number": phoneNumber});
  }

  Future<VerifyOtpResponse> VerifyOtp(String phoneNumber, String otp) {
    return apiClient.verifyOtp({"mobile_number": phoneNumber, "otp": otp});
  }
}
