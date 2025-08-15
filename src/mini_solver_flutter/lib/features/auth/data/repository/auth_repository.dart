import 'dart:async';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../common/helpers/error_helper.dart';
import '../../../../common/models/failure.dart';
import '../../../../entities/user/user.dart';
import '../../../../di.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasources.dart';

abstract class AuthRepository {
  Future<String?> get accessToken;

  Future<Either<Failure, UserProfile>> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Either<Failure, UserProfile>> signIn(String email, String password);

  Future<Either<Failure, UserProfile>> refreshToken();


  Future<Either<Failure, UserProfile>> getUserProfile();

  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl();

  final AuthRemoteDatasource _remoteDatasource = getIt();
  final UserLocalDatasource _localDatasource = getIt();
  final Logger logger = Logger();

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      final response = await _remoteDatasource.getAccountDetails();
      return Future.value(Right(response));
    } catch (e, stackTrace) {
      log('🐞Error: $e', stackTrace: stackTrace);
      return Left(
        ErrorHelper.errorToFailure(e, stacktrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, UserProfile>> signIn(String email, String password) async {
    try {
      final result = await _remoteDatasource.login(email, password);
      await _localDatasource.saveToken(result.accessToken);
      await _localDatasource.saveRefreshToken(result.refreshToken);

      return Future.value(Right(result.user));
    } on DioException catch (e) {
      print('Error: ${e.response?.data}');
      final resData = e.response?.data as Map<String, dynamic>?;
      final error = resData == null ? null : Failure.fromJson(resData);
      if (e.response?.statusCode == 401) {
        return Left(
          Failure(
            message: 'Incorrect credentials',
            code: e.response!.statusCode!,
          ),
        );
      }
      return Left(
        Failure(
          message: error?.message ?? 'Unknown error',
          code: e.response?.statusCode ?? 500,
        ),
      );
    } catch (e, stackTrace) {
      log('🐞Error: $e', stackTrace: stackTrace);
      return Left(
        Failure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserProfile>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remoteDatasource.register(
        email: email,
        fullName: fullName,
        password: password,
      );
      await _localDatasource.saveToken(result.accessToken);
      await _localDatasource.saveRefreshToken(result.refreshToken);
      return Future.value(Right(result.user));
    } catch (e, s) {
      return Left(ErrorHelper.errorToFailure(e, stacktrace: s));
    }
  }

  @override
  Future<void> logout() async {
    await _localDatasource.saveToken(null);
    await _localDatasource.saveRefreshToken(null);
  }

  @override
  Future<String?> get accessToken => _localDatasource.getAccessToken();

  @override
  Future<Either<Failure, UserProfile>> refreshToken() async {
    try {
      final refreshToken = await _localDatasource.getRefreshToken();
      if (refreshToken == null) {
        return const Left(
          Failure(
            message: 'No refresh token found',
          ),
        );
      }
      final result = await _remoteDatasource.refreshToken(refreshToken);
      await _localDatasource.saveToken(result.accessToken);
      return Future.value(Right(result.user));
    } on DioException catch (e) {
      print('Error: ${e.response?.data}');
      final resData = e.response?.data as Map<String, dynamic>?;
      final error = resData == null ? null : Failure.fromJson(resData);
      if (e.response?.statusCode == 401) {
        return Left(
          Failure(
            message: 'Incorrect credentials',
            code: e.response!.statusCode,
          ),
        );
      }
      return Left(
        Failure(
          message: error?.message ?? 'Unknown error',
          code: e.response?.statusCode ?? 500,
        ),
      );
    } catch (e, stackTrace) {
      log('🐞Error: $e', stackTrace: stackTrace);
      return Left(
        Failure(
          message: e.toString(),
        ),
      );
    }
  }
}
