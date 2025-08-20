import 'package:meatzo/data/models/authresponcemodel/verify_Otp_ResponseModel.dart';
import 'package:equatable/equatable.dart';

/// Base state class
abstract class OtpVerificationState extends Equatable {
  const OtpVerificationState();

  @override
  List<Object> get props => [];
}

/// Initial state
class OtpVerificationInitial extends OtpVerificationState {}

/// Loading state
class OtpVerificationLoading extends OtpVerificationState {}

/// Success state with response
class OtpVerificationSuccess extends OtpVerificationState {
  final VerifyOtpResponse response;

  const OtpVerificationSuccess({required this.response});

  @override
  List<Object> get props => [response];
}

/// Failure state with error message
class OtpVerificationFailure extends OtpVerificationState {
  final String error;

  const OtpVerificationFailure({required this.error});

  @override
  List<Object> get props => [error];
}
