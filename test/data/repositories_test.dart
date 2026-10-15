import 'package:dio/dio.dart';
import 'package:flutter_state/core/api_client.dart';
import 'package:flutter_state/core/token_store.dart';
import 'package:flutter_state/data/auth_repository.dart';
import 'package:flutter_state/data/federative_unit.dart';
import 'package:flutter_state/data/info_repository.dart';
import 'package:flutter_state/data/state_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

Map<String, Object?> dto({
  int id = 1,
  String nome = 'São Paulo',
  String sigla = 'SP',
}) => {
  'id': id,
  'nome': nome,
  'sigla': sigla,
  'dataHoraCadastro': '2026-01-01T00:00:00',
  'dataHoraUltimaAtualizacao': null,
};

void main() {
  late FakeKeyValueStore keychain;
  late SecureTokenStore tokens;
  late FakeAdapter adapter;
  late Dio dio;

  setUp(() {
    keychain = FakeKeyValueStore();
    tokens = SecureTokenStore(keychain);
    adapter = FakeAdapter((_) async => FakeResponse(200, {}));
    dio = createDio(
      baseUrl: 'https://api.example.com/api',
      tokens: tokens,
      onSessionExpired: () {},
      adapter: adapter,
      delay: (_) async {},
    );
  });

  group('StateRepository', () {
    late StateRepository repository;
    setUp(() => repository = StateRepository(dio));

    test(
      'list asks for the whole dataset in one page and maps the content',
      () async {
        adapter.handler = (_) async => FakeResponse(200, {
          'content': [dto(), dto(id: 2, nome: 'Rio', sigla: 'RJ')],
          'page': {'size': 100},
        });
        final units = await repository.list();
        expect(adapter.requests.single.path, '/estado/paginado');
        expect(adapter.requests.single.queryParameters, {'size': 100});
        expect(units.map((u) => u.abbreviation), ['SP', 'RJ']);
      },
    );

    test('list sends busca and sort only when provided', () async {
      adapter.handler = (_) async => FakeResponse(200, {'content': []});
      await repository.list(search: 'rio', sort: 'nome,desc');
      expect(adapter.requests.single.queryParameters, {
        'size': 100,
        'busca': 'rio',
        'sort': 'nome,desc',
      });
    });

    test('list leaves out an empty search', () async {
      adapter.handler = (_) async => FakeResponse(200, {'content': []});
      await repository.list(search: '');
      expect(adapter.requests.single.queryParameters, {'size': 100});
    });

    test('get fetches one unit by id', () async {
      adapter.handler = (_) async => FakeResponse(200, dto(id: 7));
      final unit = await repository.get(7);
      expect(adapter.requests.single.path, '/estado/7');
      expect(unit.id, 7);
    });

    test('create posts the wire body and returns the created unit', () async {
      adapter.handler = (_) async => FakeResponse(201, dto(id: 9));
      final unit = await repository.create(
        const NewFederativeUnit(abbreviation: 'SP', name: 'São Paulo'),
      );
      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/estado/');
      expect(request.data, {'nome': 'São Paulo', 'sigla': 'SP'});
      expect(unit.id, 9);
    });

    test('update puts to the id in the url, with no id in the body', () async {
      adapter.handler = (_) async => FakeResponse(200, dto(id: 3));
      final unit = await repository.update(
        FederativeUnit(
          id: 3,
          name: 'Rio',
          abbreviation: 'RJ',
          createdAt: DateTime(2026),
        ),
      );
      final request = adapter.requests.single;
      expect(request.method, 'PUT');
      expect(request.path, '/estado/3');
      expect(request.data, {'nome': 'Rio', 'sigla': 'RJ'});
      expect(unit.id, 3);
    });

    test('delete calls DELETE on the id', () async {
      adapter.handler = (_) async => FakeResponse(204);
      await repository.delete(3);
      expect(adapter.requests.single.method, 'DELETE');
      expect(adapter.requests.single.path, '/estado/3');
    });

    test('a failing request surfaces as a DioException', () async {
      adapter.handler = (_) async => FakeResponse(404);
      await expectLater(repository.get(9), throwsA(isA<DioException>()));
    });
  });

  group('AuthRepository', () {
    late AuthRepository repository;
    setUp(() => repository = AuthRepository(dio, tokens));

    test('login posts the credentials and stores the returned token', () async {
      final token = fakeJwt();
      adapter.handler = (_) async =>
          FakeResponse(200, {'token': token, 'expiresInSeconds': 3600});
      final result = await repository.login(
        username: 'admin',
        password: 'secret',
      );
      final request = adapter.requests.single;
      expect(request.path, '/auth/login');
      expect(request.data, {'username': 'admin', 'password': 'secret'});
      expect(result.token, token);
      expect(result.expiresInSeconds, 3600);
      expect(tokens.current, token);
    });

    test('login stores nothing when the request fails', () async {
      adapter.handler = (_) async => FakeResponse(401);
      await expectLater(
        repository.login(username: 'admin', password: 'wrong'),
        throwsA(isA<DioException>()),
      );
      expect(tokens.current, isNull);
    });

    test('logout clears the stored token', () async {
      await tokens.save(fakeJwt());
      await repository.logout();
      expect(tokens.current, isNull);
    });
  });

  group('InfoRepository', () {
    test(
      'backendInfo reads the build commit and time from /actuator/info',
      () async {
        adapter.handler = (_) async => FakeResponse(200, {
          'build': {'commit': 'abc1234', 'time': '2026-01-02T03:04:05Z'},
        });
        final info = await InfoRepository(dio).backendInfo();
        expect(adapter.requests.single.path, '/actuator/info');
        expect(info.commit, 'abc1234');
        expect(info.time, DateTime.utc(2026, 1, 2, 3, 4, 5));
      },
    );

    test('backendInfo rejects when the backend is down', () async {
      adapter.handler = (_) async => FakeResponse(503);
      await expectLater(
        InfoRepository(dio).backendInfo(),
        throwsA(isA<DioException>()),
      );
    });
  });
}
