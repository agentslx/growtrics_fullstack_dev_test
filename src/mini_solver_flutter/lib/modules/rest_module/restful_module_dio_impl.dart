import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../configs/env.dart';
import '../../di.dart';
import '../../features/auth/services/user_service.dart';
import '../local_storage_module/local_storage_module.dart';
import 'cancel_token.dart';
import 'options.dart';
import 'response.dart';
import 'restful_module.dart';

class RestfulModuleDioImpl implements RestfulModule {
  final LocalStorageModule localStorageModule = getIt<LocalStorageModule>();
  final Logger logger = Logger();

  Dio? _dioInstance;

  Dio get _dio {
    _dioInstance ??= _initDio();
    return _dioInstance!;
  }

  Dio getDioClient() => _dio;

  Dio _initDio() {
    final dio = Dio()
      ..options.baseUrl = AppEnv.apiBaseUrl
      ..options.connectTimeout = const Duration(minutes: 5)
      ..options.receiveTimeout = const Duration(minutes: 5)
      ..options.headers = {'Content-Type': 'application/json; charset=utf-8'}
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (
            RequestOptions options,
            RequestInterceptorHandler requestInterceptorHandler,
          ) async {
            if (options.headers['Authorization'] == 'false') {
              options.headers.remove('Authorization');
              return requestInterceptorHandler.next(options);
            }
            final authHeader = options.headers['Authorization'] as String?;
            if (authHeader?.contains('Bearer') ?? false) {
              return requestInterceptorHandler.next(options);
            }
            final String? token = await authToken;
            if (token == null) {
              return requestInterceptorHandler.next(options);
            }
            options.headers.remove('Authorization');
            options.headers.putIfAbsent('Authorization', () => 'Bearer $token');
            if (kDebugMode) {
              print('token $token');
            }
            return requestInterceptorHandler.next(options);
          },
          onError: (dioError, handler) async {
            if (dioError.response?.statusCode == 401) {
              final retry = await onUnauthenticated();
              if (retry) {
                final String? token = await authToken;

                if (token == null) {
                  return handler.next(dioError);
                }
                var response = await _dio.request(
                  dioError.requestOptions.path,
                  data: dioError.requestOptions.data,
                  queryParameters: dioError.requestOptions.queryParameters,
                  options: Options(
                    method: dioError.requestOptions.method,
                    headers: {
                      ...dioError.requestOptions.headers,
                      'Authorization': token,
                    },
                  ),
                );
                return handler.resolve(response);
              }
            }
            return handler.next(dioError);
          },
        ),
      )
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final customHeaders = await buildHeaders();
            if (customHeaders != null && customHeaders.isNotEmpty) {
              customHeaders.forEach((key, value) {
                options.headers.putIfAbsent(key, () => value);
              });
            }
            return handler.next(options);
          },
        ),
      );
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          responseBody: true,
          responseHeader: true,
          requestBody: true,
        ),
      );
    }
    return dio;
  }

  @override
  Future<CommonResponse<T>> get<T>(
    String uri, {
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
  }) async {
    final result = await _dio.get<T>(
      uri,
      queryParameters: query,
      options: Options(headers: options?.headers, contentType: options?.contentType),
    );
    return CommonResponse(
      body: result.data,
      headers: Map<String, String>.from(result.headers.map.map((key, value) => MapEntry(key, value[0]))),
      statusCode: result.statusCode,
      statusMessage: result.statusMessage,
    );
  }

  @override
  Future<CommonResponse<T>> post<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
  }) async {
    final result = await _dio.post<T>(
      uri,
      data: data,
      queryParameters: query,
      options: Options(headers: options?.headers, contentType: options?.contentType),
    );
    return CommonResponse(
      body: result.data,
      headers: Map<String, String>.from(result.headers.map.map((key, value) => MapEntry(key, value[0]))),
      statusCode: result.statusCode,
      statusMessage: result.statusMessage,
    );
  }

  @override
  Future<CommonResponse<T>> postMultipart<T>(
    String uri,
    Map<String, dynamic> formData, {
    String? fileDataKey,
    Stream<List<int>>? fileData,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
    void Function(int sent, int total)? onSendProgress,
    CommonCancelToken? cancelToken,
  }) async {
    try {
      final formDataConverted = <String, dynamic>{};
      final formDataListFiles = <String, List<MultipartFile>>{};
      final CancelToken cancelTokenDio = CancelToken();
      if (cancelToken != null) {
        cancelToken.addHandleCancel(cancelTokenDio.cancel);
      }

      log('formData: $formData');

      formData.forEach((key, value) {
        if (value is Uint8List) {
          formDataConverted[key] = MultipartFile.fromBytes(value);
        } else if (value is File) {
          formDataConverted[key] = MultipartFile.fromFileSync(value.path);
        } else if (value is List<File>) {
          formDataListFiles[key] = value.map((e) => MultipartFile.fromFileSync(e.path)).toList();
        } else {
          formDataConverted[key] = value;
        }
      });
      if (fileDataKey != null && fileData != null) {
        formDataConverted[fileDataKey] = MultipartFile.fromStream(() => fileData, await fileData.length);
      }
      final form = FormData.fromMap(formDataConverted);
      for (final key in formDataListFiles.keys) {
        form.files.addAll(formDataListFiles[key]!.map((e) => MapEntry(key, e)));
      }

      log('form: $form');

      final result = await _dio.post<T>(
        uri,
        data: form,
        queryParameters: query,
        options: Options(headers: options?.headers, contentType: 'multipart/form-data'),
        onSendProgress: (int sent, int total) {
          if (onSendProgress != null) {
            onSendProgress(sent, total);
          }
        },
        cancelToken: cancelTokenDio,
      );
      return CommonResponse(
        body: result.data,
        headers: Map<String, String>.from(result.headers.map.map((key, value) => MapEntry(key, value[0]))),
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
      );
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        throw CommonCancelException();
      }
      rethrow;
    }
  }

  @override
  Future<CommonResponse<T>> patchMultipart<T>(
    String uri,
    Map<String, dynamic> formData, {
    String? fileDataKey,
    Stream<List<int>>? fileData,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
    void Function(int sent, int total)? onSendProgress,
    CommonCancelToken? cancelToken,
  }) async {
    try {
      final formDataConverted = <String, dynamic>{};
      final CancelToken cancelTokenDio = CancelToken();
      if (cancelToken != null) {
        cancelToken.addHandleCancel(cancelTokenDio.cancel);
      }

      formData.forEach((key, value) {
        if (value is Uint8List) {
          formDataConverted[key] = MultipartFile.fromBytes(value);
        } else if (value is File) {
          formDataConverted[key] = MultipartFile.fromFileSync(value.path);
        } else {
          formDataConverted[key] = value;
        }
      });
      if (fileDataKey != null && fileData != null) {
        formDataConverted[fileDataKey] = MultipartFile.fromStream(() => fileData, await fileData.length);
      }
      final form = FormData.fromMap(formDataConverted);
      final result = await _dio.patch<T>(
        uri,
        data: form,
        queryParameters: query,
        options: Options(headers: options?.headers, contentType: 'multipart/form-data'),
        onSendProgress: (int sent, int total) {
          if (onSendProgress != null) {
            onSendProgress(sent, total);
          }
        },
        cancelToken: cancelTokenDio,
      );
      return CommonResponse(
        body: result.data,
        headers: Map<String, String>.from(result.headers.map.map((key, value) => MapEntry(key, value[0]))),
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
      );
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        throw CommonCancelException();
      }
      rethrow;
    }
  }

  @override
  Future<CommonResponse<T>> put<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final result = await _dio.put<T>(
      uri,
      data: data,
      queryParameters: query,
      options: Options(headers: options?.headers, contentType: options?.contentType),
      onSendProgress: onSendProgress,
    );
    return CommonResponse(
      body: result.data,
      headers: Map<String, String>.from(result.headers.map.map((key, value) => MapEntry(key, value[0]))),
      statusCode: result.statusCode,
      statusMessage: result.statusMessage,
    );
  }

  @override
  Future<CommonResponse<T>> patch<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
  }) async {
    final result = await _dio.patch<T>(
      uri,
      data: data,
      queryParameters: query,
      options: Options(headers: options?.headers, contentType: options?.contentType),
    );
    return CommonResponse(
      body: result.data,
      headers: Map<String, String>.from(result.headers.map.map((key, value) => MapEntry(key, value[0]))),
      statusCode: result.statusCode,
      statusMessage: result.statusMessage,
    );
  }

  @override
  Future<CommonResponse<T>> delete<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
  }) async {
    final result = await _dio.delete<T>(
      uri,
      data: data,
      queryParameters: query,
      options: Options(headers: options?.headers, contentType: options?.contentType),
    );
    return CommonResponse(
      body: result.data,
      headers: Map<String, String>.from(result.headers.map.map((key, value) => MapEntry(key, value[0]))),
      statusCode: result.statusCode,
      statusMessage: result.statusMessage,
    );
  }

  @override
  Future<File> download(
    String uri, {
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
    String? path,
  }) async {
    await _dio.download(
      uri,
      path!,
      queryParameters: query,
      options: Options(headers: options?.headers, contentType: options?.contentType),
    );
    return File(path);
  }

  @override
  Future<String?> get authToken async => localStorageModule.get<String>(AppEnv.kPrefAccessToken);

  @override
  Future<void> removeAuthToken() async {
    await localStorageModule.remove<String>(AppEnv.kPrefAccessToken);
  }

  @override
  Future<void> saveAuthToken(String authToken) async {
    await localStorageModule.set<String>(AppEnv.kPrefAccessToken, authToken);
  }

  @override
  Future<void> init() async {
    _dio;
  }

  @override
  Future<Map<String, dynamic>?> buildHeaders() async => null;

  @override
  Future<bool> onUnauthenticated() {
    UserService userService = getIt<UserService>();
    final refreshTokenResult = userService.refreshToken();

    return refreshTokenResult.then((value) {
      return true;
    }).catchError((e) {
      Future.delayed(const Duration(milliseconds: 200), () {
        userService.logout();
      });
      return false;
    });
  }
}
