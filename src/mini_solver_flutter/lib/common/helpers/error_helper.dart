import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/failure.dart';

class ErrorHelper {
  ErrorHelper._();

  static Failure errorToFailure(dynamic error, {String? defaultMessage, StackTrace? stacktrace}) {
    if (error is DioException) {
      final res = error.response;
      try {
        if (res != null) {
          if (res.data is String) {
            // if text is short, use it. Else, response unknown error
            if ((res.data as String).length < 100 && (res.data as String).isNotEmpty) {
              return Failure(
                message: (res.data as String).tr(),
                code: res.statusCode!,
              );
            }
          } else if (res.data is Map<String, dynamic>) {
            return Failure.fromJson(
              res.data as Map<String, dynamic>,
            );
          }
        }
      } catch (e, s) {
        log('Error while process exception $e, StackTrace $s');
      }

      return Failure(
        message: mapStatusCodeToError[error.response?.statusCode] ?? defaultMessage ?? 'Unknown error',
        code: error.response?.statusCode ?? 500,
      );
    }

    if (stacktrace != null) {
      log('Error: $error, StackTrace: $stacktrace');
      // Sentry.captureException(
      //   error,
      //   stackTrace: stacktrace,
      // );
    }

    return const Failure(
      message: 'Unknown error',
      code: 500,
    );
  }

  static Map<int, String> mapStatusCodeToError = {
    400: 'Bad request',
    401: 'Unauthorized',
    403: 'Forbidden',
    404: 'Not found',
    405: 'Method not allowed',
    406: 'Not acceptable',
    408: 'Request timeout',
    409: 'Conflict',
    410: 'Gone',
    411: 'Length required',
    412: 'Precondition failed',
    413: 'Payload too large',
    414: 'URI too long',
    415: 'Unsupported media type',
    416: 'Range not satisfiable',
    417: 'Expectation failed',
    418: 'I’m a teapot',
    422: 'Unprocessable entity',
    429: 'Too many requests',
    500: 'Internal server error',
    501: 'Not implemented',
    502: 'Bad gateway',
    503: 'Service unavailable',
    504: 'Gateway timeout',
    505: 'HTTP version not supported',
  };
}
