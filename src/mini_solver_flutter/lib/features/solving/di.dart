import 'package:get_it/get_it.dart';

import 'data/datasources/solving_remote_datasource.dart';
import 'data/repository/solving_repository.dart';
import 'cubits/solving_session_cubit/solving_session_cubit.dart';

Future<void> initSolvingDi(GetIt getIt) async {
  getIt
    ..registerLazySingleton<SolvingRemoteDatasource>(SolvingRemoteDatasourceImpl.new)
    ..registerLazySingleton<SolvingRepository>(SolvingRepositoryImpl.new)
    ..registerLazySingleton<SolvingSessionCubit>(SolvingSessionCubit.new);
}
