import 'package:meatzo/data/models/authresponcemodel/auth_response_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthResponseModel response;

  AuthSuccess({required this.response});
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure({required this.message});
}
