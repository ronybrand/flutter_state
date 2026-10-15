import 'package:dio/dio.dart';

class BackendInfo {
  const BackendInfo({required this.commit, required this.time});

  final String commit;
  final DateTime time;
}

class InfoRepository {
  InfoRepository(this._dio);

  final Dio _dio;

  Future<BackendInfo> backendInfo() async {
    final response = await _dio.get<Map<String, Object?>>('/actuator/info');
    final build = response.data!['build']! as Map<String, Object?>;
    return BackendInfo(
      commit: build['commit']! as String,
      time: DateTime.parse(build['time']! as String),
    );
  }
}
