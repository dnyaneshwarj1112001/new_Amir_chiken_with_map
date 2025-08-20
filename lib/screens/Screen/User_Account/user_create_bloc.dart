import 'package:meatzo/screens/Screen/User_Account/user_create_event.dart';
import 'package:meatzo/screens/Screen/User_Account/user_create_state.dart';
import 'package:bloc/bloc.dart';
import 'package:email_validator/email_validator.dart';

class UserCreateBloc extends Bloc<UserCreateEvent, UserCreateState> {
  UserCreateBloc() : super(UserInitial()) {
    on<EmailTextChangeEvent>((event, emit) {
      if (event.emailValue == "") {
        emit(UserTextInvalidState("Email cannot be empty"));
      } else if (EmailValidator.validate(event.emailValue) == false) {
        emit(UserTextInvalidState("Please Enter Valid Email"));
      } else {
        emit(validemail("Thats Gret that is Valid Mail"));
      }
    });
  }
}
