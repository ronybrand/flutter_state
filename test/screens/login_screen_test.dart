import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_state/data/auth_repository.dart';
import 'package:flutter_state/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/app_harness.dart';
import '../support/fakes.dart';
import '../support/mocks.dart';

void main() {
  late MockAuthRepository authRepository;
  late MockStateRepository stateRepository;
  late AppHarness harness;

  final username = find.byKey(const Key('username'));
  final password = find.byKey(const Key('password'));
  final logIn = find.byKey(const Key('submit-login'));

  bool enabled(WidgetTester tester) =>
      tester.widget<FilledButton>(logIn).onPressed != null;

  List<Override> overrides() => [
    stateRepositoryProvider.overrideWithValue(stateRepository),
    authRepositoryProvider.overrideWithValue(authRepository),
  ];

  void stubLogin() {
    when(
      () => authRepository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {
      final token = fakeJwt();
      await harness.tokens.save(token);
      return LoginResult(token: token, expiresInSeconds: 3600);
    });
  }

  void stubLoginFailure() {
    when(
      () => authRepository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
        ),
      ),
    );
  }

  Future<void> fill(WidgetTester tester) async {
    await tester.enterText(username, 'admin');
    await tester.enterText(password, 'secret');
    await tester.pump();
  }

  setUp(() {
    authRepository = MockAuthRepository();
    stateRepository = MockStateRepository();
    when(
      () => stateRepository.list(
        search: any(named: 'search'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((_) async => []);
    when(() => authRepository.logout()).thenAnswer((_) async {});
    harness = AppHarness(overrides: overrides());
  });

  testWidgets('keeps Log in disabled until both fields are filled', (
    tester,
  ) async {
    await harness.pump(tester, location: '/login');
    expect(enabled(tester), isFalse);
    await tester.enterText(username, 'admin');
    await tester.pump();
    expect(enabled(tester), isFalse);
    await tester.enterText(password, 'secret');
    await tester.pump();
    expect(enabled(tester), isTrue);
  });

  testWidgets('hides the password and tells password managers what is what', (
    tester,
  ) async {
    await harness.pump(tester, location: '/login');
    final pass = tester.widget<TextField>(password);
    final user = tester.widget<TextField>(username);
    expect(pass.obscureText, isTrue);
    expect(pass.autofillHints, contains(AutofillHints.password));
    expect(user.autofillHints, contains(AutofillHints.username));
    expect(user.autocorrect, isFalse);
  });

  testWidgets('signs in and goes to the list', (tester) async {
    stubLogin();
    await harness.pump(tester, location: '/login');
    await fill(tester);

    await tester.tap(logIn);
    await tester.pumpAndSettle();

    verify(() => authRepository.login(username: 'admin', password: 'secret'))
        .called(1);
    expect(find.byKey(const Key('log-out')), findsOneWidget);
    expect(find.byKey(const Key('username')), findsNothing);
  });

  testWidgets('shows an error and stays when the credentials are rejected', (
    tester,
  ) async {
    stubLoginFailure();
    await harness.pump(tester, location: '/login');
    await fill(tester);

    await tester.tap(logIn);
    await tester.pumpAndSettle();

    expect(find.text('Invalid username or password.'), findsOneWidget);
    expect(find.byKey(const Key('username')), findsOneWidget);
  });

  testWidgets('ignores a second press while the first request is in flight', (
    tester,
  ) async {
    final pending = Completer<LoginResult>();
    when(
      () => authRepository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => pending.future);
    await harness.pump(tester, location: '/login');
    await fill(tester);

    await tester.tap(logIn);
    await tester.pump();
    await tester.tap(logIn, warnIfMissed: false);
    await tester.pump();

    verify(
      () => authRepository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).called(1);
    expect(enabled(tester), isFalse);
  });

  testWidgets('lets the user try again after a failure', (tester) async {
    stubLoginFailure();
    await harness.pump(tester, location: '/login');
    await fill(tester);
    await tester.tap(logIn);
    await tester.pumpAndSettle();

    await tester.tap(logIn);
    await tester.pumpAndSettle();

    verify(
      () => authRepository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).called(2);
  });

  testWidgets('shows the public demo credentials', (tester) async {
    await harness.pump(tester, location: '/login');
    expect(find.textContaining('admin'), findsWidgets);
    expect(find.byKey(const Key('demo-credentials')), findsOneWidget);
  });

  testWidgets('meets the tap target, label and contrast rules', (tester) async {
    final handle = tester.ensureSemantics();
    await harness.pump(tester, location: '/login');
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
