import 'dart:convert';

import 'package:dio/dio.dart';

import 'local_storage_service.dart';
import 'type_registry.dart'; // Ensure to import TypeRegistry

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
          await localStorage.deleteStoredRequest(request.id); // Only delete on success
        } else {
          print("Request ${request.url} failed with status ${response.statusCode}");
        }
      } catch (e) {
        print("Failed to synchronize request: ${request.url}, Error: $e");
        // Optionally, add logic to handle retries or logging
      }
    }

    onCompletion?.call();
  }

  Future<Response> executeStoredRequest(StoredRequest request) async {
    var registryEntry = TypeRegistry.getByName(request.typeBoxName);
    if (registryEntry == null) {
      throw Exception("Type ${request.typeBoxName} for request ${request.url} is not registered.");
    }

    var body = request.body != null ? registryEntry.fromJson(json.decode(request.body!)) : null;
    var queryParams = request.queryParams != null ? json.decode(request.queryParams!) : null;

    try {
      switch (request.method) {
        case 'POST':
          return await dio.post(request.url,
              data: body != null ? registryEntry.toJson(body) : null,
              queryParameters: queryParams);
        case 'GET':
          return await dio.get(request.url,
              queryParameters: queryParams);
        case 'PUT':
          return await dio.put(request.url,
              data: body != null ? registryEntry.toJson(body) : null,
              queryParameters: queryParams);
        case 'DELETE':
          return await dio.delete(request.url,
              data: body != null ? registryEntry.toJson(body) : null,
              queryParameters: queryParams);
        default:
          throw Exception('Unsupported HTTP method');
      }
    } catch (e) {
      print("Error executing request ${request.method} ${request.url}: $e");
      throw e; // Rethrowing exception to be handled by the calling function
    }
  }
}
