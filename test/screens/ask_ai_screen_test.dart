import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_state/data/ask_repository.dart';
import 'package:flutter_state/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/app_harness.dart';
import '../support/mocks.dart';

void main() {
  late MockAskRepository repository;
  late AppHarness harness;

  List<Override> overrides() => [
    askRepositoryProvider.overrideWithValue(repository),
  ];

  setUp(() {
    repository = MockAskRepository();
    harness = AppHarness(overrides: overrides());
    when(
      () => repository.ask(
        question: any(named: 'question'),
        language: any(named: 'language'),
      ),
    ).thenAnswer(
      (_) async =>
          const AskResponse(answer: '## Resposta\n\n- 27 estados brasileiros.'),
    );
  });

  testWidgets(
    'shows a localized question form and submits the trimmed question',
    (tester) async {
      await harness.pump(tester, location: '/ask-ai');

      expect(find.text('Ask about the Brazilian states'), findsOneWidget);
      expect(find.byKey(const Key('ask-ai-question')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('ask-ai-question')),
        '  How many states are there?  ',
      );
      await tester.pump();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('ask-ai-question')))
            .controller!
            .text,
        '  How many states are there?  ',
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('ask-ai-submit')))
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.byKey(const Key('ask-ai-submit')));
      await tester.pump();
      await tester.pumpAndSettle();

      verify(
        () => repository.ask(
          question: 'How many states are there?',
          language: 'en',
        ),
      ).called(1);
      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.text('Resposta'), findsOneWidget);
      expect(find.text('27 estados brasileiros.'), findsOneWidget);
    },
  );

  testWidgets('disables duplicate submissions while the answer is pending', (
    tester,
  ) async {
    final pending = Future<AskResponse>.delayed(
      const Duration(seconds: 1),
      () => const AskResponse(answer: 'Done'),
    );
    when(
      () => repository.ask(
        question: any(named: 'question'),
        language: any(named: 'language'),
      ),
    ).thenAnswer((_) => pending);
    await harness.pump(tester, location: '/ask-ai');
    await tester.enterText(
      find.byKey(const Key('ask-ai-question')),
      'Question',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('ask-ai-submit')));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('ask-ai-question')))
          .enabled,
      isFalse,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('ask-ai-submit')))
          .onPressed,
      isNull,
    );

    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets(
    'shows a readable error and request id when the API rejects a question',
    (tester) async {
      const requestId = '123e4567-e89b-12d3-a456-426614174000';
      when(
        () => repository.ask(
          question: any(named: 'question'),
          language: any(named: 'language'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/ask'),
          response: Response(
            requestOptions: RequestOptions(path: '/ask'),
            statusCode: 400,
            data: {'requestId': requestId},
          ),
        ),
      );
      await harness.pump(tester, location: '/ask-ai');
      await tester.enterText(
        find.byKey(const Key('ask-ai-question')),
        'Question',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('ask-ai-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Failed to reach the AI assistant.'), findsOneWidget);
      expect(find.text('Reference ID: $requestId'), findsOneWidget);
    },
  );

  testWidgets('offers the AI page from the public state list', (tester) async {
    await harness.pump(tester);

    await tester.tap(find.byKey(const Key('ask-ai')));
    await tester.pumpAndSettle();

    expect(find.text('Ask about the Brazilian states'), findsOneWidget);
  });
}
