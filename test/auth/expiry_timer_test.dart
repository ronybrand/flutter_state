import 'package:fake_async/fake_async.dart';
import 'package:flutter_state/auth/expiry_timer.dart';
import 'package:flutter_state/core/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  final base = DateTime.utc(2026, 1, 1, 12);

  test('calls onExpired when the stored token reaches its exp', () {
    fakeAsync((async) {
      final tokens = SecureTokenStore(FakeKeyValueStore());
      var now = base;
      var expired = 0;
      tokens.save(fakeJwt(now: base, expiresIn: const Duration(seconds: 30)));
      async.flushMicrotasks();
      ExpiryTimer(tokens, () => expired++, now: () => now).schedule();

      now = base.add(const Duration(seconds: 29));
      async.elapse(const Duration(seconds: 29));
      expect(expired, 0);

      now = base.add(const Duration(seconds: 31));
      async.elapse(const Duration(seconds: 2));
      expect(expired, 1);
    });
  });

  test('does nothing without a token', () {
    fakeAsync((async) {
      var expired = 0;
      ExpiryTimer(
        SecureTokenStore(FakeKeyValueStore()),
        () => expired++,
        now: () => base,
      ).schedule();
      async.elapse(const Duration(days: 30));
      expect(expired, 0);
    });
  });

  test('cancel stops the pending call', () {
    fakeAsync((async) {
      final tokens = SecureTokenStore(FakeKeyValueStore());
      var expired = 0;
      tokens.save(fakeJwt(now: base, expiresIn: const Duration(seconds: 30)));
      async.flushMicrotasks();
      final timer = ExpiryTimer(tokens, () => expired++, now: () => base)
        ..schedule()
        ..cancel();
      async.elapse(const Duration(minutes: 5));
      expect(expired, 0);
      expect(timer, isNotNull);
    });
  });

  test('scheduling again replaces the previous timer instead of stacking', () {
    fakeAsync((async) {
      final tokens = SecureTokenStore(FakeKeyValueStore());
      var now = base;
      var expired = 0;
      tokens.save(fakeJwt(now: base, expiresIn: const Duration(seconds: 30)));
      async.flushMicrotasks();
      ExpiryTimer(tokens, () => expired++, now: () => now)
        ..schedule()
        ..schedule();
      now = base.add(const Duration(seconds: 31));
      async.elapse(const Duration(seconds: 31));
      expect(expired, 1);
    });
  });

  test(
    'survives a token that outlives the 32-bit timer limit (about 24.8 days)',
    () {
      // On the web a Timer longer than that fires immediately, so the delay is
      // clamped and the timer re-arms instead of expiring the session early.
      fakeAsync((async) {
        final tokens = SecureTokenStore(FakeKeyValueStore());
        var now = base;
        var expired = 0;
        const life = Duration(days: 40);
        tokens.save(fakeJwt(now: base, expiresIn: life));
        async.flushMicrotasks();
        ExpiryTimer(tokens, () => expired++, now: () => now).schedule();

        const step = Duration(days: 25);
        now = base.add(step);
        async.elapse(step);
        expect(expired, 0, reason: 'the clamped timer fired early: re-arm');

        const rest = Duration(days: 15, minutes: 1);
        now = base.add(step + rest);
        async.elapse(rest);
        expect(expired, 1);
      });
    },
  );
}
