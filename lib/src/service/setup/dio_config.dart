import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class DioConfig {
  final String baseUrl;
  final Map<String, dynamic> headers;
  late final Dio _dio;

  DioConfig({required this.baseUrl, required this.headers});

  initialize() {
    _dio = Dio();
    _dio.options.headers = headers;
    GetIt.instance.registerSingleton<Dio>(_dio);
  }

  Dio get dio => _dio;
}
