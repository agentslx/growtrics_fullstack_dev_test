import 'package:get_it/get_it.dart';

import 'data/datasources/solving_remote_datasource.dart';
import 'data/repository/solving_repository.dart';

Future<void> initSolvingDi(GetIt getIt) async {
  getIt
    ..registerLazySingleton<SolvingRemoteDatasource>(SolvingRemoteDatasourceImpl.new)
    ..registerLazySingleton<SolvingRepository>(SolvingRepositoryImpl.new);
}
