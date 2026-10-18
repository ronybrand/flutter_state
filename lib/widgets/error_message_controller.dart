import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/api_error_message.dart';

const _defaultDuration = Duration(seconds: 5);

// The error only arrives after the timeout and retries (~45s) with an empty
// screen, so the usual 5s would vanish before being read.
const _apiUnavailableDuration = Duration(seconds: 60);

/// A transient error banner's state: set it, and it clears itself.
class ErrorMessageController extends ChangeNotifier {
  String? _error;
  String? _requestId;
  Timer? _timer;

  String? get error => _error;
  String? get requestId => _requestId;

  void show(String message, [String? requestId, Duration? duration]) {
    _timer?.cancel();
    _error = message;
    _requestId = requestId;
    _timer = Timer(
      duration ??
          (message == apiUnavailableMessage
              ? _apiUnavailableDuration
              : _defaultDuration),
      clear,
    );
    notifyListeners();
  }

  void clear() {
    _timer?.cancel();
    _timer = null;
    _error = null;
    _requestId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
