import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_state/core/token_store.dart';

/// In-memory stand-in for the platform keychain, with switches to simulate a
/// locked or broken one.
class FakeKeyValueStore implements KeyValueStore {
  final Map<String, String> values = {};
  bool failReads = false;
  bool failWrites = false;
  bool failDeletes = false;

  @override
  Future<String?> read(String key) async {
    if (failReads) throw Exception('keychain locked');
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (failWrites) throw Exception('keychain locked');
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    if (failDeletes) throw Exception('keychain locked');
    values.remove(key);
  }
}

typedef RequestHandler = Future<FakeResponse> Function(RequestOptions options);

class FakeResponse {
  FakeResponse(this.status, [this.body]);

  final int status;
  final Object? body;
}

/// A Dio adapter that answers from a function instead of the network, and
/// records every request it saw.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  RequestHandler handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final response = await handler(options);
    final text = response.body == null ? '' : jsonEncode(response.body);
    return ResponseBody.fromString(
      text,
      response.status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// An unsigned JWT-shaped token expiring [expiresIn] from [now].
String fakeJwt({Duration expiresIn = const Duration(hours: 1), DateTime? now}) {
  final base = (now ?? DateTime.now()).toUtc();
  final exp = base.add(expiresIn).millisecondsSinceEpoch ~/ 1000;
  final payload = base64Url.encode(utf8.encode(jsonEncode({'exp': exp})));
  return 'header.${payload.replaceAll('=', '')}.signature';
}

/// A real HTTP 500: unlike a response-less DioException, the app treats it as a
/// backend failure, not as the API being unavailable.
DioException serverError(String path) {
  final options = RequestOptions(path: path);
  return DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: 500),
  );
}
