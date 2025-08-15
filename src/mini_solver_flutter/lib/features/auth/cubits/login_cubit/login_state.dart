part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.email,
    this.password,
    this.loginStatus = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final Email? email;
  final Password? password;
  final FormzSubmissionStatus loginStatus;
  final String? errorMessage;

  bool get isValid => email?.isValid == true && password?.isValid == true;

  @override
  List<Object?> get props => [
        loginStatus,
        email,
        password,
        errorMessage,
      ];

  LoginState copyWith({
    Email? email,
    Password? password,
    FormzSubmissionStatus? loginStatus,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      loginStatus: loginStatus ?? this.loginStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
