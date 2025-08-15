import 'dart:io';

import 'cancel_token.dart';
import 'options.dart';
import 'response.dart';

abstract class RestfulModule {
  Future<void> init();

  Future<String?> get authToken;

  Future<void> saveAuthToken(String authToken);

  Future<void> removeAuthToken();

  Future<CommonResponse<T>> get<T>(
    String uri, {
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
  });

  Future<CommonResponse<T>> post<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
  });

  Future<CommonResponse<T>> postMultipart<T>(
    String uri,
    Map<String, dynamic> formData, {
    String? fileDataKey,
    Stream<List<int>>? fileData,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
    void Function(int sent, int total)? onSendProgress,
    CommonCancelToken? cancelToken,
  });

  Future<CommonResponse<T>> patchMultipart<T>(
    String uri,
    Map<String, dynamic> formData, {
    String? fileDataKey,
    Stream<List<int>>? fileData,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
    void Function(int sent, int total)? onSendProgress,
    CommonCancelToken? cancelToken,
  });

  Future<CommonResponse<T>> put<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
    void Function(int p1, int p2)? onSendProgress,
  });

  Future<CommonResponse<T>> patch<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
  });

  Future<CommonResponse<T>> delete<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
  });

  Future<File> download(
    String uri, {
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
    String? path,
  });

  Future<Map<String, dynamic>?> buildHeaders();

  Future<bool> onUnauthenticated() async => false;
}
