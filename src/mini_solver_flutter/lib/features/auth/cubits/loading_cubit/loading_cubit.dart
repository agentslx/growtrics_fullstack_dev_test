import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di.dart';
import '../../../../entities/user/user.dart';
import '../../data/repository/auth_repository.dart';
import '../../services/user_service.dart';

part 'loading_state.dart';

class LoadingCubit extends Cubit<LoadingState> {
  LoadingCubit() : super(const LoadingState()) {
    initData();
  }

  final AuthRepository _authRepository = getIt();

  Future<void> initData() async {
    final userProfile = await _authRepository.refreshToken();

    userProfile.fold((e) {
      // User is not authenticated
      emit(state.copyWith(authenticationState: AuthenticationState.unauthenticated));
    }, (r) {
      // User is authenticated
      UserService userService = getIt<UserService>();
      userService.setUserDetails(r);
      emit(state.copyWith(
        authenticationState: r.isVerified ? AuthenticationState.loggedIn : AuthenticationState.loggedInNeedVerify,
      ));
    });

    if (state.authenticationState == AuthenticationState.loggedIn) {
      return;
    }
  }
}
