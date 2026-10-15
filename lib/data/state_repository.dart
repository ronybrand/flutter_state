import 'package:dio/dio.dart';

import 'federative_unit.dart';

/// Matches the backend's actual REST contract (/estado), not translated:
/// renaming it here would break real calls.
const _basePath = '/estado';

class StateRepository {
  StateRepository(this._dio);

  final Dio _dio;

  /// size=100 covers the whole dataset (27 units) in one page: the backend only
  /// exposes the paginated endpoint, and a closed domain never needs a second
  /// page. `busca` and `sort` only enter the query string when provided; their
  /// absence means "no filter" and "no explicit ordering".
  Future<List<FederativeUnit>> list({String? search, String? sort}) async {
    final response = await _dio.get<Map<String, Object?>>(
      '$_basePath/paginado',
      queryParameters: {
        'size': 100,
        if (search != null && search.isNotEmpty) 'busca': search,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
      },
    );
    final content = response.data!['content']! as List<Object?>;
    return [
      for (final item in content)
        FederativeUnit.fromJson(item! as Map<String, Object?>),
    ];
  }

  Future<FederativeUnit> get(int id) async {
    final response = await _dio.get<Map<String, Object?>>('$_basePath/$id');
    return FederativeUnit.fromJson(response.data!);
  }

  Future<FederativeUnit> create(NewFederativeUnit unit) async {
    final response = await _dio.post<Map<String, Object?>>(
      '$_basePath/',
      data: unit.toRequestJson(),
    );
    return FederativeUnit.fromJson(response.data!);
  }

  Future<FederativeUnit> update(FederativeUnit unit) async {
    final response = await _dio.put<Map<String, Object?>>(
      '$_basePath/${unit.id}',
      data: unit.toRequestJson(),
    );
    return FederativeUnit.fromJson(response.data!);
  }

  Future<void> delete(int id) async {
    await _dio.delete<void>('$_basePath/$id');
  }
}
