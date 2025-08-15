import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../../common/forms/email_model.dart';
import '../../../../common/forms/name_model.dart';
import '../../../../common/forms/password_model.dart';
import '../../../../di.dart';
import '../../data/repository/auth_repository.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterState()) {}

  AuthRepository authRepository = getIt<AuthRepository>();

  void onEmailChanged(String value) {
    final email = Email.dirty(value.trim());
    emit(state.copyWith(
      email: email,
    ));
  }

  void onFullNameChanged(String value) {
    emit(state.copyWith(
      fullName: Name.dirty(value.trim()),
    ));
  }

  void onPasswordChanged(String value) {
    final password = Password.dirty(false, value);
    emit(state.copyWith(
      password: password,
    ));
  }

  Future<void> requestEmailVerify() async {
    if (state.signUpStatus.isInProgress) return;

    if (!state.isValid) {
      emit(
        state.copyWith(
          registerStatus: FormzSubmissionStatus.canceled,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        signUpStatus: FormzSubmissionStatus.inProgress,
      ),
    );
    final registerFailureOrResponse = await authRepository.signUp(
      fullName: state.fullName!.value,
      email: state.email!.value,
      password: state.password!.value,
    );

    await registerFailureOrResponse.fold(
      (failure) {
        emit(
          state.copyWith(
            signUpStatus: FormzSubmissionStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (r) async {
        emit(
          state.copyWith(
            signUpStatus: FormzSubmissionStatus.success,
          ),
        );
      },
    );
  }
}
