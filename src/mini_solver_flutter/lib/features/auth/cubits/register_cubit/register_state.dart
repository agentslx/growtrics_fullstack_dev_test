part of 'register_cubit.dart';

class RegisterState extends Equatable {
  const RegisterState({
    this.email,
    this.fullName,
    this.password,
    this.signUpStatus = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final Name? fullName;
  final Email? email;
  final Password? password;
  final FormzSubmissionStatus signUpStatus;
  final String? errorMessage;

  bool get isValid => email?.isValid == true && password?.isValid == true && fullName?.isValid == true;

  @override
  List<Object?> get props => [
        signUpStatus,
        email,
        fullName,
        password,
        errorMessage,
      ];

  RegisterState copyWith({
    Email? email,
    Name? fullName,
    Password? password,
    FormzSubmissionStatus? registerStatus,
    FormzSubmissionStatus? signUpStatus,
    String? errorMessage,
  }) {
    return RegisterState(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      password: password ?? this.password,
      signUpStatus: signUpStatus ?? this.signUpStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
