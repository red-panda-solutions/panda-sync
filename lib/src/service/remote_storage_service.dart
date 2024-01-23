import 'package:dio/dio.dart';

typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

class RemoteStorageService<T> {
  final Dio dio;
  final JsonFactory<T> fromJson;

  RemoteStorageService({required this.dio, required this.fromJson});

  Future<T> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final response = await dio.get(path, queryParameters: queryParameters);
    return fromJson(response.data);
  }

  Future<List<T>> getList(String path, {Map<String, dynamic>? queryParameters}) async {
    final response = await dio.get(path, queryParameters: queryParameters);
    List<dynamic> jsonData = response.data;
    return jsonData.map((json) => fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<T> post(String path, {dynamic data, Map<String, dynamic>? options}) async {
    final response = await dio.post(path, data: data, options: Options(headers: options));
    return fromJson(response.data);
  }

  Future<T> put(String path, {dynamic data, Map<String, dynamic>? options}) async {
    final response = await dio.put(path, data: data, options: Options(headers: options));
    return fromJson(response.data);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? options}) async {
    return await dio.delete(path, data: data, options: Options(headers: options));
  }
}
