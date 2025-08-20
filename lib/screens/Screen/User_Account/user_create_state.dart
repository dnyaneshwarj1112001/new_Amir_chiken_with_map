abstract class UserCreateState {}

class UserTextInvalidState extends UserCreateState {
  final String message;

  UserTextInvalidState(this.message);
}

class UserInitial extends UserCreateState {}

// ignore: camel_case_types
class validemail extends UserCreateState {
  // ignore: non_constant_identifier_names
  final String Message;
  validemail(this.Message);
}

class emtytext extends UserCreateState {}
