import 'package:get_it/get_it.dart';

import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasources.dart';
import 'data/repository/auth_repository.dart';
import 'services/user_service.dart';

Future<void> initAuthDi(GetIt getIt) async {
  // Data
  getIt
    ..registerLazySingleton<AuthRemoteDatasource>(AuthRemoteDatasourceImpl.new)
    ..registerLazySingleton<UserLocalDatasource>(UserLocalDatasourceImpl.new)
    ..registerLazySingleton<AuthRepository>(AuthRepositoryImpl.new)
    ..registerLazySingleton<UserService>(UserServiceImpl.new);
}
