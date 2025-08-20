abstract class UserCreateEvent {}

/// Event triggered when the email is invalid.
class EmailTextChangeEvent extends UserCreateEvent {
  final String emailValue;
   EmailTextChangeEvent(this.emailValue);
}

/// Event triggered when the email is valid.
class ValidEmail extends UserCreateEvent {
  final String errorMessage;
   ValidEmail(this.errorMessage);
}
