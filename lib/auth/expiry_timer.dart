import 'dart:async';

import '../core/jwt.dart';
import '../core/token_store.dart';

// A Timer longer than 2^31-1 ms (about 24.8 days) overflows its 32-bit delay on
// the web and fires at once.
const _maxDelay = Duration(milliseconds: 2147483647);

/// Nothing on the device announces that a JWT's `exp` has passed, and the app can
/// stay open (or in the background) well past it: a timer ends the session on
/// time instead of waiting for the next request to fail with a 401.
class ExpiryTimer {
  ExpiryTimer(this._tokens, this._onExpired, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final TokenStore _tokens;
  final void Function() _onExpired;
  final DateTime Function() _now;
  Timer? _timer;

  void schedule() {
    cancel();
    final token = _tokens.current;
    final expiry = token == null ? null : tokenExpiry(token);
    if (expiry == null) return;
    var delay = expiry.difference(_now().toUtc());
    if (delay.isNegative) delay = Duration.zero;
    if (delay > _maxDelay) delay = _maxDelay;
    _timer = Timer(delay, () {
      // A clamped timer fires early: only expire if the token really is done.
      final current = _tokens.current;
      if (current != null && isTokenValid(current, now: _now())) {
        schedule();
      } else {
        _onExpired();
      }
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
