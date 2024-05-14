import 'dart:convert';

import 'package:dio/dio.dart';

import 'local_storage_service.dart';

class SynchronizationService {
  final LocalStorageService localStorage;
  final Dio dio;

  SynchronizationService(this.localStorage, {Dio? dioClient})
      : dio = dioClient ?? Dio();

  Future<void> processQueue({Function? onCompletion}) async {
    var storedRequests = await localStorage.getAllStoredRequests();
    for (StoredRequest request in storedRequests) {
      try {
        Response response = await executeStoredRequest(request);
        if (response.statusCode == 200 || response.statusCode == 204) {
          await localStorage
              .deleteStoredRequest(request.id); // Only delete on success
        } else {
          print(
              "Request ${request.url} failed with status ${response.statusCode}");
        }
      } catch (e) {
        print("Failed to synchronize request: ${request.url}, Error: $e");
        // Optionally, add logic to handle retries or logging
      }
    }

    onCompletion?.call();
  }

  Future<Response> executeStoredRequest(StoredRequest request) async {
    try {
      switch (request.method) {
        case 'POST':
          return await dio.post(request.url,
              data: json.decode(request.body ?? '{}'),
              queryParameters: json.decode(request.queryParams ?? '{}'));
        case 'GET':
          return await dio.get(request.url,
              queryParameters: json.decode(request.queryParams ?? '{}'));
        case 'PUT':
          return await dio.put(request.url,
              data: json.decode(request.body ?? '{}'),
              queryParameters: json.decode(request.queryParams ?? '{}'));
        case 'DELETE':
          return await dio.delete(request.url,
              data: json.decode(request.body ?? '{}'),
              queryParameters: json.decode(request.queryParams ?? '{}'));
        default:
          throw Exception('Unsupported HTTP method');
      }
    } catch (e) {
      print("Error executing request ${request.method} ${request.url}: $e");
      throw e; // Rethrowing exception to be handled by the calling function
    }
  }
}
