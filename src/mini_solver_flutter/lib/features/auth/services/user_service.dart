import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../common/models/failure.dart';
import '../../../di.dart';
import '../../../entities/user/user.dart';
import '../../../router.dart';
import '../data/repository/auth_repository.dart';
import '../router.dart';

/// Provide APIs to get user details and logout event
abstract class UserService {
  Future<Either<Failure, void>> refreshToken();

  Future<void> setUserDetails(UserProfile? userEntity);

  UserProfile? getUserDetails();

  UserProfile? get userDetails;

  Future<void> logout();

  void registerUserDetailsListener(void Function(UserProfile? userProfile) listener);

  void removeUserDetailsListener(void Function(UserProfile? userProfile) listener);

  void registerLogoutListener(void Function() listener);

  void removeLogoutListener(void Function() listener);

  Future<void> refreshUserDetails();

  ValueNotifier<UserProfile?> get userNotifier;
}

class UserServiceImpl implements UserService {
  UserServiceImpl() {
    _init();
  }

  final ValueNotifier<UserProfile?> _userNotifier = ValueNotifier<UserProfile?>(null);

  UserProfile? _userEntity;
  final AuthRepository userRepository = getIt<AuthRepository>();

  final List<void Function(UserProfile? userEntity)> _userDetailsListeners = [];
  final List<void Function()> _logoutListeners = [];

  Future<void> _init() async {
  }

  @override
  Future<void> setUserDetails(UserProfile? userEntity) async {
    _userEntity = userEntity;
    for (final callback in _userDetailsListeners) {
      try {
        callback(userEntity);
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrintStack(stackTrace: s);
      }
    }
    _userNotifier.value = userEntity;
  }

  @override
  UserProfile? getUserDetails() => _userEntity;

  @override
  Future<void> refreshUserDetails() async {
    final response = await userRepository.getUserProfile();
    return response.fold(
      (l) {
        setUserDetails(null);
      },
      (res) => setUserDetails(res),
    );
  }

  @override
  Future<void> logout() async {
    try {
      try {
        await userRepository.logout();
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrintStack(stackTrace: s);
      }

      for (final fn in _logoutListeners) {
        try {
          fn();
        } catch (e, s) {
          debugPrint(e.toString());
          debugPrintStack(stackTrace: s);
        }
      }
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 500)).then(
          (_) async {
            await setUserDetails(null);

            AppRouter.navigatorKey.currentContext!.go(AuthRouter.signUp);
          },
        ),
      );
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
    }
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    final response = await userRepository.refreshToken();
    return response.fold(
      (l) => Left(l),
      (r) {
        setUserDetails(r);
        return const Right(null);
      },
    );
  }

  @override
  void registerUserDetailsListener(void Function(UserProfile? userEntity) listener) {
    _userDetailsListeners.add(listener);
  }

  @override
  void registerLogoutListener(void Function() listener) {
    _logoutListeners.add(listener);
  }

  @override
  void removeLogoutListener(void Function() listener) {
    _logoutListeners.remove(listener);
  }

  @override
  void removeUserDetailsListener(void Function(UserProfile? userEntity) listener) {
    _userDetailsListeners.remove(listener);
  }

  @override
  UserProfile? get userDetails => _userEntity;

  @override
  ValueNotifier<UserProfile?> get userNotifier => _userNotifier;
}
