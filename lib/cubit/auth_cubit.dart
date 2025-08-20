import 'package:meatzo/core/network/api_client.dart';
import 'package:meatzo/core/network/dio_client.dart';
import 'package:meatzo/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit()
      : _authRepository = AuthRepository(ApiClient(DioClient.dio)),
        super(AuthInitial());

  void loginWithPhone(String phone) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(phone);
    
      emit(AuthSuccess(response: response));
    } catch (e) {
    
      emit(AuthFailure(message: e.toString()));
    }
  }
}
