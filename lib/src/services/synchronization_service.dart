import 'package:dio/dio.dart';
import 'local_storage_service.dart';
import 'dart:convert'; // For JSON encoding and decoding

class SynchronizationService {
  final LocalStorageService localStorage;
  final Dio dio;

  SynchronizationService(this.localStorage, {Dio? dioClient})
      : dio = dioClient ?? Dio();

  Future<void> processQueue() async {
    final allRequests = await localStorage.getAllStoredRequests();

    for (var request in allRequests) {
      try {
        Response response = await _sendRequest(request);
        if (response.statusCode! >= 200 && response.statusCode! < 300) {
          await localStorage.deleteStoredRequest(request.id);
        } else {
          print('Request failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Error sending stored request: $e');
      }
    }
  }

  Future<Response> _sendRequest(StoredRequest request) async {
    switch (request.method) {
      case 'POST':
        return dio.post(
            request.url,
            data: json.decode(request.body ?? '{}'),
            queryParameters: json.decode(request.queryParams ?? '{}')
        );
      case 'GET':
        return dio.get(
            request.url,
            queryParameters: json.decode(request.queryParams ?? '{}')
        );
      case 'PUT':
        return dio.put(
            request.url,
            data: json.decode(request.body ?? '{}'),
            queryParameters: json.decode(request.queryParams ?? '{}')
        );
      case 'DELETE':
        return dio.delete(
            request.url,
            data: json.decode(request.body ?? '{}'),
            queryParameters: json.decode(request.queryParams ?? '{}')
        );
      default:
        throw Exception('Unsupported HTTP method');
    }
  }
}
