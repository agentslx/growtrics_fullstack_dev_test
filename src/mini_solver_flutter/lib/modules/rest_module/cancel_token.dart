import 'dart:async';

import 'options.dart';

/// You can cancel a request by using a cancel token.
/// One token can be shared with different requests.
/// when a token's [cancel] method invoked, all requests
/// with this token will be cancelled.
class CommonCancelToken {

  CommonCancelToken() {
    _completer = Completer<Object?>();
  }
  final List<void Function(Object? reason)> _cancelFuncs = [];

  /// If request have been canceled, save the cancel Error.
  Object? _cancelError;

  /// If request have been canceled, save the cancel Error.
  Object? get cancelError => _cancelError;

  late Completer<Object?> _completer;

  CommonRequestOptions? requestOptions;

  /// whether cancelled
  bool get isCancelled => _cancelError != null;

  /// When cancelled, this future will be resolved.
  Future<Object?> get whenCancel => _completer.future;

  /// Cancel the request
  void cancel([Object? reason]) {
    _cancelError = reason;
    for (final element in _cancelFuncs) {
      element(_cancelError);
    }
    if (!_completer.isCompleted) {
      _completer.complete(_cancelError);
    }
  }

  void addHandleCancel(void Function(Object? reason) handleCancel) {
    _cancelFuncs.add(handleCancel);
  }
}

class CommonCancelException extends Error {
  CommonCancelException();
}
