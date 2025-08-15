import '../../../../configs/env.dart';
import '../../../../di.dart';
import '../../../../modules/local_storage_module/local_storage_module.dart';

abstract class UserLocalDatasource {
  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> saveToken(String? token);

  Future<void> saveRefreshToken(String? token);
}

class UserLocalDatasourceImpl extends UserLocalDatasource {
  final LocalStorageModule storageModule = getIt();

  @override
  Future<String?> getAccessToken() async => storageModule.get<String>(AppEnv.kPrefAccessToken);


  @override
  Future<String?> getRefreshToken() async => storageModule.get<String>(AppEnv.kPrefRefreshToken);

  @override
  Future<void> saveRefreshToken(String? token) {
    if (token == null) {
      return storageModule.remove<String>(AppEnv.kPrefRefreshToken);
    }
    return storageModule.set<String>(AppEnv.kPrefRefreshToken, token);
  }

  @override
  Future<void> saveToken(String? token) {
    if (token == null) {
      return storageModule.remove<String>(AppEnv.kPrefAccessToken);
    }
    return storageModule.set<String>(AppEnv.kPrefAccessToken, token);
  }
}
