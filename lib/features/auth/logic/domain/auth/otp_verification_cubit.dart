import 'package:meatzo/data/repositories/auth_repository.dart';
import 'package:meatzo/features/auth/logic/domain/auth/otp_verification_state.dart';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Otpverificationcubit extends Cubit<OtpVerificationState> {
  final AuthRepository authRepository;

  Otpverificationcubit(this.authRepository) : super(OtpVerificationInitial());
  void verifyOtp(String PhoneNumber, String otp) async {
    emit(OtpVerificationLoading());
    try {
      final response = await authRepository.VerifyOtp(PhoneNumber, otp);
      print(
          "$response------------------------------------------------------------------------------------------------------->>>");
      if (!response.hasError) {
        final token = response.token;
        print(
            "$token------------------------------------------------------------------------------------------------------->>>");
        final user = response.user;
        print(user);
        print(
            "=============================================================================>");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", token);
        await prefs.setString("user_id", user.id.toString());
        await prefs.setString("user_name", user.name.toString());
        await prefs.setString("user_phone", user.mobileNumber.toString());
        await prefs.setString("user_email", user.profilePhotoUrl.toString());

        emit(OtpVerificationSuccess(response: response));
      } else {
        emit(OtpVerificationFailure(error: "errorMessage));"));
      }
    } catch (e) {
      if (e is DioError) {
        emit(OtpVerificationFailure(error: e.toString()));
      } else {
        emit(OtpVerificationFailure(error: "An unexpected error occurred."));
      }
    }
  }
}
