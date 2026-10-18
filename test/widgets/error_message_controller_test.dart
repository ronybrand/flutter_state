import 'package:fake_async/fake_async.dart';
import 'package:flutter_state/core/api_error_message.dart';
import 'package:flutter_state/widgets/error_message_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts empty', () {
    final controller = ErrorMessageController();
    expect(controller.error, isNull);
    expect(controller.requestId, isNull);
    controller.dispose();
  });

  test('show sets the message and the request id and notifies', () {
    final controller = ErrorMessageController();
    var notified = 0;
    controller.addListener(() => notified++);

    controller.show('Boom', 'id-1');

    expect(controller.error, 'Boom');
    expect(controller.requestId, 'id-1');
    expect(notified, 1);
    controller.dispose();
  });

  test('clears itself after the default 5s', () {
    fakeAsync((async) {
      final controller = ErrorMessageController()..show('Boom');
      async.elapse(const Duration(milliseconds: 4999));
      expect(controller.error, 'Boom');
      async.elapse(const Duration(milliseconds: 1));
      expect(controller.error, isNull);
      controller.dispose();
    });
  });

  test('restarts the timer when a new error replaces the previous one', () {
    fakeAsync((async) {
      final controller = ErrorMessageController()..show('first');
      async.elapse(const Duration(seconds: 4));
      controller.show('second');
      async.elapse(const Duration(seconds: 4));
      expect(controller.error, 'second');
      controller.dispose();
    });
  });

  test('honours a custom duration', () {
    fakeAsync((async) {
      final controller = ErrorMessageController()
        ..show('Boom', null, const Duration(milliseconds: 100));
      async.elapse(const Duration(milliseconds: 100));
      expect(controller.error, isNull);
      controller.dispose();
    });
  });

  test('clear empties it at once and cancels the pending timer', () {
    fakeAsync((async) {
      final controller = ErrorMessageController()
        ..show('Boom', 'id-1')
        ..clear();
      expect(controller.error, isNull);
      expect(controller.requestId, isNull);
      controller.show('Again');
      async.elapse(const Duration(milliseconds: 4999));
      expect(controller.error, 'Again');
      controller.dispose();
    });
  });

  test('dispose leaves no timer behind', () {
    fakeAsync((async) {
      ErrorMessageController()
        ..show('Boom')
        ..dispose();
      expect(async.pendingTimers, isEmpty);
    });
  });

  test('keeps the API-unavailable message well past the default 5s', () {
    fakeAsync((async) {
      final controller = ErrorMessageController()..show(apiUnavailableMessage);
      async.elapse(const Duration(milliseconds: 59999));
      expect(controller.error, apiUnavailableMessage);
      async.elapse(const Duration(milliseconds: 1));
      expect(controller.error, isNull);
      controller.dispose();
    });
  });
}
