import 'dart:convert'; // For JSON encoding and decoding

import 'package:dio/dio.dart';
import 'package:isar/isar.dart';

import '../../panda_sync.dart';

part 'local_storage_service.g.dart'; // Isar generates this part file

@Collection()
class StoredRequest {
  Id id = Isar.autoIncrement;
  late String url;
  late String method;
  late String? queryParams;
  late String? body;
}

@Collection()
class DataObject {
  Id id = Isar.autoIncrement;
  late String type; // 'Task', 'Note', etc.
  late String jsonData;
}

class LocalStorageService {
  final Isar isar;

  LocalStorageService(this.isar);

  // Store a single instance of T
  Future<void> storeData<T extends Identifiable>(T data) async {
    String jsonData = json.encode(data);
    await isar.writeTxn(() async {
      final existingData = await isar.dataObjects
          .filter()
          .typeEqualTo(T.toString())
          .idEqualTo(data.id)
          .findFirst();
      if (existingData != null) {
        existingData.jsonData = jsonData;
        await isar.dataObjects.put(existingData);
      } else {
        await isar.dataObjects.put(DataObject()
          ..type = T.toString()
          ..id = data.id
          ..jsonData = jsonData);
      }
    });
  }

  // Store a list of T
  Future<void> storeDataList<T extends Identifiable>(List<T> dataList) async {
    await isar.writeTxn(() async {
      for (var data in dataList) {
        String jsonData = json.encode(data);
        final existingData = await isar.dataObjects
            .filter()
            .typeEqualTo(T.toString())
            .idEqualTo(data.id)
            .findFirst();
        if (existingData != null) {
          existingData.jsonData = jsonData;
          await isar.dataObjects.put(existingData);
        } else {
          await isar.dataObjects.put(DataObject()
            ..type = T.toString()
            ..id = data.id
            ..jsonData = jsonData);
        }
      }
    });
  }

  Future<List<T>> getData<T extends Identifiable>(
      String typeName, Function fromJson) async {
    final dataObjects =
        await isar.dataObjects.filter().typeEqualTo(typeName).findAll();
    return dataObjects
        .map((dObj) => fromJson(json.decode(dObj.jsonData)) as T)
        .toList();
  }

  Future<void> updateCachedData<T extends Identifiable>(T data) async {
    String jsonData = json.encode(data);
    await isar.writeTxn(() async {
      final existingData = await isar.dataObjects
          .filter()
          .typeEqualTo(T.toString())
          .idEqualTo(data.id)
          .findFirst();
      if (existingData != null) {
        existingData.jsonData = jsonData;
        await isar.dataObjects.put(existingData);
      }
    });
  }

  Future<void> removeData<T extends Identifiable>(
      String typeName, dynamic id) async {
    await isar.writeTxn(() async {
      final data = await isar.dataObjects
          .filter()
          .typeEqualTo(typeName)
          .idEqualTo(id)
          .findFirst();
      if (data != null) {
        await isar.dataObjects.delete(data.id);
      }
    });
  }

  Future<Response<T>> getCachedResponse<T extends Identifiable>(
      String url) async {
    final query =
        await isar.dataObjects.filter().typeEqualTo(T.toString()).findFirst();
    if (query != null) {
      try {
        T data = json.decode(query.jsonData) as T;
        return Response<T>(
          data: data,
          requestOptions: RequestOptions(path: url),
          statusCode: 200,
        );
      } catch (e) {
        print('Error decoding data: $e');
        return Response<T>(
          requestOptions: RequestOptions(path: url),
          statusCode: 204,
        );
      }
    }
    return Response<T>(
      requestOptions: RequestOptions(path: url),
      statusCode: 204,
    );
  }

  Future<void> storeRequest(String url, String method,
      Map<String, dynamic>? queryParams, dynamic data) async {
    await isar.writeTxn(() async {
      await isar.storedRequests.put(StoredRequest()
        ..url = url
        ..method = method
        ..queryParams = json.encode(queryParams ?? {})
        ..body = json.encode(data));
    });
  }

  Future<List<StoredRequest>> getAllStoredRequests() async {
    return isar.storedRequests.where().findAll();
  }

  Future<void> deleteStoredRequest(int id) async {
    await isar.writeTxn(() async {
      await isar.storedRequests.delete(id);
    });
  }
}
