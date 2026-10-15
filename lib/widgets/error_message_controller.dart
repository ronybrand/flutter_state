import 'dart:async';

import 'package:flutter/foundation.dart';

const _defaultDuration = Duration(seconds: 5);

/// A transient error banner's state: set it, and it clears itself.
class ErrorMessageController extends ChangeNotifier {
  String? _error;
  String? _requestId;
  Timer? _timer;

  String? get error => _error;
  String? get requestId => _requestId;

  void show(
    String message, [
    String? requestId,
    Duration duration = _defaultDuration,
  ]) {
    _timer?.cancel();
    _error = message;
    _requestId = requestId;
    _timer = Timer(duration, clear);
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
