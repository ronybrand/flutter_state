import 'package:flutter_state/core/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late FakeKeyValueStore keychain;
  late SecureTokenStore store;

  setUp(() {
    keychain = FakeKeyValueStore();
    store = SecureTokenStore(keychain);
  });

  test('has no token before anything is saved', () {
    expect(store.current, isNull);
  });

  test('save makes the token readable synchronously and persists it', () async {
    final token = fakeJwt();
    await store.save(token);
    expect(store.current, token);
    expect(keychain.values[tokenKey], token);
  });

  test('keeps the session in memory when the keychain write fails', () async {
    keychain.failWrites = true;
    final token = fakeJwt();
    await store.save(token);
    expect(store.current, token);
  });

  test('clear forgets the token and removes it from the keychain', () async {
    await store.save(fakeJwt());
    await store.clear();
    expect(store.current, isNull);
    expect(keychain.values, isEmpty);
  });

  test(
    'clear still forgets the token when the keychain delete fails',
    () async {
      await store.save(fakeJwt());
      keychain.failDeletes = true;
      await store.clear();
      expect(store.current, isNull);
    },
  );

  group('load (app start)', () {
    test('restores a valid token from the keychain into memory', () async {
      final token = fakeJwt();
      keychain.values[tokenKey] = token;
      expect(await store.load(), token);
      expect(store.current, token);
    });

    test('returns null when nothing is stored', () async {
      expect(await store.load(), isNull);
    });

    test('drops and deletes an expired token', () async {
      keychain.values[tokenKey] = fakeJwt(
        expiresIn: const Duration(minutes: -1),
      );
      expect(await store.load(), isNull);
      expect(store.current, isNull);
      expect(keychain.values, isEmpty);
    });

    test('drops a stored value that is not a jwt', () async {
      keychain.values[tokenKey] = 'garbage';
      expect(await store.load(), isNull);
    });

    test(
      'treats an unreadable keychain as logged out instead of crashing',
      () async {
        keychain.failReads = true;
        expect(await store.load(), isNull);
        expect(store.current, isNull);
      },
    );
  });
}
