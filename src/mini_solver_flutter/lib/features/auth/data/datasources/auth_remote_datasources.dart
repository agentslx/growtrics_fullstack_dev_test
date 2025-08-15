import '../../../../di.dart';
import '../../../../entities/user/user.dart';
import '../../../../modules/rest_module/restful_module.dart';
import '../models/login_response_model.dart';

abstract class AuthRemoteDatasource {
  Future<LoginResponseModel> login(String username, String password);

  Future<LoginResponseModel> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<UserProfile> getAccountDetails();

  Future<UserProfile> updateAccountDetails({
    required String fullName,
    String? gender,
    String? avatar,
  });

  Future<LoginResponseModel> refreshToken(String refreshToken);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final RestfulModule restfulModule = getIt();

  @override
  Future<LoginResponseModel> login(String email, String password) async {
    final response = await restfulModule.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<LoginResponseModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await restfulModule.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'name': fullName,
        'email': email,
        'password': password,
      },
    );
    return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserProfile> getAccountDetails() async {
    final response = await restfulModule.get<Map<String, dynamic>>(
      '/users/me',
    );
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserProfile> updateAccountDetails({
    required String fullName,
    String? gender,
    String? avatar,
  }) async {
    final response = await restfulModule.put<Map<String, dynamic>>(
      '/users/profile',
      data: <String, dynamic>{
        'name': fullName,
        'gender': gender,
        'avatar': avatar,
      },
    );
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<LoginResponseModel> refreshToken(String refreshToken) async {
    final response = await restfulModule.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: <String, dynamic>{
        'refresh_token': refreshToken,
      },
    );
    return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
