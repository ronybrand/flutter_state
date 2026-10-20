import 'package:dio/dio.dart';

const askTimeout = Duration(seconds: 55);

class AskResponse {
  const AskResponse({required this.answer});

  final String answer;

  factory AskResponse.fromJson(Map<String, Object?> json) =>
      AskResponse(answer: json['answer']! as String);
}

class AskRepository {
  AskRepository(this._dio);

  final Dio _dio;

  Future<AskResponse> ask({
    required String question,
    required String language,
  }) async {
    final response = await _dio.post<Map<String, Object?>>(
      '/ask',
      data: {'question': question},
      queryParameters: {'lang': language},
      options: Options(receiveTimeout: askTimeout),
    );
    return AskResponse.fromJson(response.data!);
  }
}
