import 'package:isar/isar.dart';
import 'package:dio/dio.dart';
import 'dart:convert'; // For JSON encoding and decoding

part 'local_storage_service.g.dart'; // Isar generates this part file

@Collection()
class StoredRequest {
  Id id = Isar.autoIncrement;
  late String url;
  late String method;
  late String? queryParams; // JSON string
  late String? body; // JSON string
}

class LocalStorageService {
  final Isar isar;

  LocalStorageService(this.isar);

  Future<List<StoredRequest>> getAllStoredRequests() async {
    return isar.storedRequests.where().findAll();
  }

  Future<void> deleteStoredRequest(int id) async {
    await isar.writeTxn(() async {
      await isar.storedRequests.delete(id);
    });
  }

  Future<void> storeRequest(String url, String method, Map<String, dynamic>? queryParams, dynamic data) async {
    await isar.writeTxn(() async {
      await isar.storedRequests.put(StoredRequest()
        ..url = url
        ..method = method
        ..queryParams = json.encode(queryParams ?? {})
        ..body = json.encode(data));
    });
  }

  // Assuming T is a type that can be serialized/deserialized with json.encode/json.decode
  Future<Response<T>?> getCachedResponse<T>(String url, String method, Map<String, dynamic>? queryParams) async {
    final query = await isar.storedRequests.filter()
        .urlEqualTo(url)
        .and().methodEqualTo(method)
        .and().queryParamsEqualTo(json.encode(queryParams ?? {}))
        .findFirst();

    if (query != null && query.body != null) {
      try {
        // Assuming the data stored in 'body' is a JSON string that can be deserialized to type T
        T data = json.decode(query.body!) as T;
        return Response<T>(
          data: data,
          requestOptions: RequestOptions(path: url),
          statusCode: 200, // Indicate that data comes from cache
        );
      } catch (e) {
        // Handle JSON parsing error
        print('Error decoding data: $e');
      }
    }
    return null;
  }
}

