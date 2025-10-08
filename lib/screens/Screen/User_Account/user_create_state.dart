abstract class UserCreateState {}

class UserTextInvalidState extends UserCreateState {
  final String message;

  UserTextInvalidState(this.message);
}

class UserInitial extends UserCreateState {}

class validemail extends UserCreateState {
  final String Message;
  validemail(this.Message);
}

class emtytext extends UserCreateState {}
