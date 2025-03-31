import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:isar/isar.dart';

import '../../panda_sync.dart';

part 'local_storage_service.g.dart';

@Collection()
class StoredRequest {
  Id id = Isar.autoIncrement;
  late String url;
  late String method;
  late String? queryParams;
  late String? body;
  late String typeBoxName;
}

@Collection()
class DataObject {
  Id id = Isar.autoIncrement;
  late String type;
  late String jsonData;
}

/// A service for local storage operations using Isar database.
///
/// The [LocalStorageService] class provides methods to store, retrieve, and manage
/// data objects and stored requests in the Isar database.
class LocalStorageService {
  final Isar isar;

  /// Creates an instance of [LocalStorageService] with the given Isar database instance.
  LocalStorageService(this.isar);

  /// Stores a data object of type [T] in the local storage.
  ///
  /// - [data]: The data object to store.
  ///
  /// Throws an exception if the type [T] is not registered.
  Future<void> storeData<T extends Identifiable>(T data) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    String jsonData = json.encode(registryEntry.toJson(data));
    await isar.writeTxn(() async {
      final existingData = await isar.dataObjects
          .filter()
          .typeEqualTo(registryEntry.boxName)
          .idEqualTo(data.id)
          .findFirst();
      if (existingData != null) {
        existingData.jsonData = jsonData;
        await isar.dataObjects.put(existingData);
      } else {
        await isar.dataObjects.put(DataObject()
          ..type = registryEntry.boxName
          ..id = data.id
          ..jsonData = jsonData);
      }
    });
  }

  /// Stores a list of data objects of type [T] in the local storage.
  ///
  /// - [dataList]: The list of data objects to store.
  ///
  /// Throws an exception if the type [T] is not registered.
  Future<void> storeDataList<T extends Identifiable>(List<T> dataList) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    await isar.writeTxn(() async {
      for (var data in dataList) {
        String jsonData = json.encode(registryEntry.toJson(data));
        final existingData = await isar.dataObjects
            .filter()
            .typeEqualTo(registryEntry.boxName)
            .idEqualTo(data.id)
            .findFirst();
        if (existingData != null) {
          existingData.jsonData = jsonData;
          await isar.dataObjects.put(existingData);
        } else {
          await isar.dataObjects.put(DataObject()
            ..type = registryEntry.boxName
            ..id = data.id
            ..jsonData = jsonData);
        }
      }
    });
  }

  /// Retrieves all data objects of type [T] from the local storage.
  ///
  /// Returns a list of data objects.
  ///
  /// Throws an exception if the type [T] is not registered.
  Future<List<T>> getData<T extends Identifiable>() async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    final dataObjects = await isar.dataObjects
        .filter()
        .typeEqualTo(registryEntry.boxName)
        .findAll();
    return dataObjects
        .map((dObj) => registryEntry.fromJson(json.decode(dObj.jsonData)) as T)
        .toList();
  }

  /// Updates a cached data object of type [T] in the local storage.
  ///
  /// - [data]: The data object to update.
  ///
  /// Throws an exception if the type [T] is not registered.
  Future<void> updateCachedData<T extends Identifiable>(T data) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    String jsonData = json.encode(registryEntry.toJson(data));
    await isar.writeTxn(() async {
      final existingData = await isar.dataObjects
          .filter()
          .typeEqualTo(registryEntry.boxName)
          .idEqualTo(data.id)
          .findFirst();
      if (existingData != null) {
        existingData.jsonData = jsonData;
        await isar.dataObjects.put(existingData);
      }
    });
  }

  /// Removes a data object of type [T] from the local storage by its id.
  ///
  /// - [id]: The id of the data object to remove.
  ///
  /// Throws an exception if the type [T] is not registered.
  Future<void> removeData<T extends Identifiable>(dynamic id) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    await isar.writeTxn(() async {
      final data = await isar.dataObjects
          .filter()
          .typeEqualTo(registryEntry.boxName)
          .idEqualTo(id)
          .findFirst();
      if (data != null) {
        await isar.dataObjects.delete(data.id);
      }
    });
  }

  /// Retrieves a cached response of type [T] from the local storage for the given URL.
  ///
  /// - [url]: The URL for which to retrieve the cached response.
  ///
  /// Returns a [Response] object containing the cached data.
  ///
  /// Throws an exception if the type [T] is not registered.
  Future<Response<T>> getCachedResponse<T extends Identifiable>(
      String url) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    final query = await isar.dataObjects
        .filter()
        .typeEqualTo(registryEntry.boxName)
        .findFirst();
    if (query != null) {
      try {
        T data = registryEntry.fromJson(json.decode(query.jsonData)) as T;
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

  /// Stores a request in the local storage.
  ///
  /// - [url]: The URL of the request.
  /// - [method]: The HTTP method of the request.
  /// - [queryParams]: The query parameters of the request.
  /// - [data]: The data object to store with the request.
  ///
  /// Throws an exception if the type [T] is not registered.
  Future<void> storeRequest<T extends Identifiable>(String url, String method,
      Map<String, dynamic>? queryParams, T data) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    await isar.writeTxn(() async {
      await isar.storedRequests.put(StoredRequest()
        ..url = url
        ..method = method
        ..queryParams = json.encode(queryParams ?? {})
        ..body = json.encode(registryEntry.toJson(data))
        ..typeBoxName = registryEntry.boxName);
    });
  }

  /// Retrieves all stored requests from the local storage.
  ///
  /// Returns a list of [StoredRequest] objects.
  Future<List<StoredRequest>> getAllStoredRequests() async {
    return isar.storedRequests.where().findAll();
  }

  /// Deletes a stored request from the local storage by its id.
  ///
  /// - [id]: The id of the stored request to delete.
  Future<void> deleteStoredRequest(int id) async {
    await isar.writeTxn(() async {
      await isar.storedRequests.delete(id);
    });
  }
}
