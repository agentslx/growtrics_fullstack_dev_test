import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../../common/forms/email_model.dart';
import '../../../../common/forms/password_model.dart';
import '../../../../di.dart';
import '../../data/repository/auth_repository.dart';
import '../../services/user_service.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState()) {}

  AuthRepository authRepository = getIt<AuthRepository>();

  void onEmailChanged(String value) {
    emit(state.copyWith(
      email: Email.dirty(value),
    ));
  }

  void onPasswordChanged(String value) {
    emit(state.copyWith(
      password: Password.dirty(true, value),
    ));
  }

  Future<void> login() async {
    if (!state.isValid) {
      emit(state.copyWith(loginStatus: FormzSubmissionStatus.canceled));
      return;
    }
    if (state.loginStatus.isInProgress) return;
    emit(state.copyWith(loginStatus: FormzSubmissionStatus.inProgress));

    final failureOrResponse = await authRepository.signIn(state.email!.value, state.password!.value);
    failureOrResponse.fold(
      (failure) {
        emit(
          state.copyWith(
            loginStatus: FormzSubmissionStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (auth) async {
        final userService = getIt<UserService>();
        await userService.refreshUserDetails();
        emit(state.copyWith(loginStatus: FormzSubmissionStatus.success));
      },
    );
  }
}
