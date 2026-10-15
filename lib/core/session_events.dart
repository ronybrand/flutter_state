import 'dart:async';

/// A tiny pub/sub between the HTTP client and the auth controller. The client's
/// 401 handler runs outside the widget tree and cannot depend on the controller
/// (the controller depends on the repository, which depends on the client), so
/// it announces here and the controller listens.
class SessionEvents {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get expired => _controller.stream;

  void notifyExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }

  void dispose() => _controller.close();
}
