part of 'loading_cubit.dart';

class LoadingState extends Equatable {
  const LoadingState({
    this.authenticationState = AuthenticationState.initial,
    this.errorMessage,
  });

  final AuthenticationState authenticationState;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        authenticationState,
        errorMessage,
      ];

  LoadingState copyWith({
    AuthenticationState? authenticationState,
    String? errorMessage,
    bool? clearErrorMessage,
  }) {
    return LoadingState(
      authenticationState: authenticationState ?? this.authenticationState,
      errorMessage: clearErrorMessage == true ? null : errorMessage ?? this.errorMessage,
    );
  }
}
