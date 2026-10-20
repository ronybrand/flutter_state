import 'package:dio/dio.dart';
import 'package:flutter_state/core/api_client.dart';
import 'package:flutter_state/core/token_store.dart';
import 'package:flutter_state/data/ask_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late FakeAdapter adapter;
  late AskRepository repository;

  setUp(() {
    adapter = FakeAdapter(
      (_) async => FakeResponse(200, {'answer': '27 states.'}),
    );
    final dio = createDio(
      baseUrl: 'https://api.example.com/api',
      tokens: SecureTokenStore(FakeKeyValueStore()),
      onSessionExpired: () {},
      adapter: adapter,
      delay: (_) async {},
    );
    repository = AskRepository(dio);
  });

  test('ask posts the question and language and returns the answer', () async {
    final response = await repository.ask(
      question: 'How many states are there?',
      language: 'en',
    );

    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.path, '/ask');
    expect(request.queryParameters, {'lang': 'en'});
    expect(request.data, {'question': 'How many states are there?'});
    expect(response.answer, '27 states.');
  });

  test('ask allows enough time for the AI response', () async {
    await repository.ask(question: 'Pergunta', language: 'pt');

    expect(adapter.requests.single.receiveTimeout, const Duration(seconds: 55));
  });

  test('ask propagates backend errors', () async {
    adapter.handler = (_) async =>
        FakeResponse(400, {'message': 'Invalid question'});

    await expectLater(
      repository.ask(question: '', language: 'pt'),
      throwsA(isA<DioException>()),
    );
  });
}
