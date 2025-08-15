import 'package:get_it/get_it.dart';

import 'features/auth/di.dart';
import 'modules/local_storage_module/local_storage_module.dart';
import 'modules/local_storage_module/shared_pref_impl.dart';
import 'modules/rest_module/restful_module.dart';
import 'modules/rest_module/restful_module_dio_impl.dart';
import 'router.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  getIt.registerSingleton<LocalStorageModule>(SharedPrefLocalStorageImpl());
  final restfulModule = RestfulModuleDioImpl();

  await restfulModule.init();
  getIt
    ..registerLazySingleton(restfulModule.getDioClient)
    ..registerSingleton<RestfulModule>(restfulModule)
    ..registerLazySingleton<AppRouter>(AppRouter.new);

  await initAuthDi(getIt);
}
