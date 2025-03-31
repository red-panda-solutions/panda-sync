import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:panda_sync/src/services/connectivity_service.dart';
import 'package:panda_sync/src/services/local_storage_service.dart';
import 'package:panda_sync/src/services/synchronization_service.dart';
import 'package:panda_sync/src/utils/isar_manager.dart';

import '../panda_sync.dart';

/// A client that provides offline-first capabilities for HTTP operations.
///
/// The [OfflineFirstClient] class allows for seamless offline access and synchronization
/// of data by caching responses locally and synchronizing with the server when connectivity is restored.
class OfflineFirstClient {
  static final OfflineFirstClient _instance =
      OfflineFirstClient._createInstance();
  final Dio dio;
  final LocalStorageService localStorage;
  final ConnectivityService connectivityService;
  final SynchronizationService synchronizationService;
  late Future<String?> Function() getToken;
  late Future<void> Function() refreshToken;

  /// Factory constructor for [OfflineFirstClient].
  ///
  /// Returns the singleton instance of [OfflineFirstClient].
  factory OfflineFirstClient() => _instance;

  OfflineFirstClient._(this.dio, this.localStorage, this.connectivityService,
      this.synchronizationService) {
    connectivityService.connectivityStream.listen(handleConnectivityChange);
    dio.interceptors.add(_createAuthInterceptor());
  }

  @visibleForTesting
  OfflineFirstClient.createForTest(this.dio, this.localStorage,
      this.connectivityService, this.synchronizationService);

  /// Creates and initializes an instance of [OfflineFirstClient].
  ///
  /// This method sets up [Dio], [LocalStorageService], [ConnectivityService], and [SynchronizationService].
  static OfflineFirstClient _createInstance() {
    Dio dio = Dio(); // Optionally configure Dio here
    LocalStorageService localStorage =
        LocalStorageService(IsarManager.getIsarInstance());
    ConnectivityService connectivityService = ConnectivityService();
    SynchronizationService synchronizationService =
        SynchronizationService(localStorage);

    return OfflineFirstClient._(
        dio, localStorage, connectivityService, synchronizationService);
  }

  /// Sends a GET request to the specified [url] and returns the response.
  ///
  /// If the device is offline, it fetches the data from local storage.
  ///
  /// - [url]: The endpoint URL.
  /// - [queryParameters]: Optional query parameters.
  Future<Response<T>> get<T extends Identifiable>(String url,
      {Map<String, dynamic>? queryParameters}) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    if (await connectivityService.isConnected()) {
      try {
        Response<dynamic> response =
            await dio.get(url, queryParameters: queryParameters);
        T result = registryEntry.fromJson(response.data);
        await localStorage.storeData<T>(result);
        return _dioResponse<T>(result, response);
      } catch (e) {
        return await fetchFromLocalStorage<T>(url);
      }
    } else {
      return await fetchFromLocalStorage<T>(url);
    }
  }

  /// Sends a POST request to the specified [url] with [data] and returns the response.
  ///
  /// If the device is offline, it stores the request locally and queues it for later execution.
  ///
  /// - [url]: The endpoint URL.
  /// - [data]: The data to be sent in the request body.
  /// - [queryParameters]: Optional query parameters.
  Future<Response<T>> post<T extends Identifiable>(String url, T data,
      {Map<String, dynamic>? queryParameters}) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    if (await connectivityService.isConnected()) {
      try {
        Response<dynamic> response = await dio.post(url,
            data: registryEntry.toJson(data), queryParameters: queryParameters);
        T result = registryEntry.fromJson(response.data);
        await localStorage.storeData<T>(data);
        return _dioResponse<T>(result, response);
      } catch (e) {
        await localStorage.storeRequest(url, 'POST', queryParameters, data);
        await localStorage.updateCachedData<T>(data);
        return Response<T>(
          requestOptions: RequestOptions(path: url),
          statusCode: 206,
          statusMessage: e.toString(),
        );
      }
    } else {
      await localStorage.storeRequest(url, 'POST', queryParameters, data);
      await localStorage.updateCachedData<T>(data);
      return Response<T>(
        requestOptions: RequestOptions(path: url),
        statusCode: 206,
        statusMessage: 'No connectivity',
      );
    }
  }

  /// Sends a PUT request to the specified [url] with [data] and returns the response.
  ///
  /// If the device is offline, it stores the request locally and queues it for later execution.
  ///
  /// - [url]: The endpoint URL.
  /// - [data]: The data to be sent in the request body.
  /// - [queryParameters]: Optional query parameters.
  Future<Response<T>> put<T extends Identifiable>(String url, T data,
      {Map<String, dynamic>? queryParameters}) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    if (await connectivityService.isConnected()) {
      try {
        Response<dynamic> response = await dio.put(url,
            data: registryEntry.toJson(data), queryParameters: queryParameters);
        await localStorage.updateCachedData<T>(data);
        T result = registryEntry.fromJson(response.data);
        return _dioResponse<T>(result, response);
      } catch (e) {
        await localStorage.storeRequest(url, 'PUT', queryParameters, data);
        await localStorage.updateCachedData<T>(data);
        return Response<T>(
          data: data,
          requestOptions: RequestOptions(path: url),
          statusCode: 206,
          statusMessage: e.toString(),
        );
      }
    } else {
      await localStorage.storeRequest(url, 'PUT', queryParameters, data);
      await localStorage.updateCachedData<T>(data);
      return Response<T>(
        data: data,
        requestOptions: RequestOptions(path: url),
        statusCode: 206,
        statusMessage: 'No connectivity',
      );
    }
  }

  /// Sends a DELETE request to the specified [url] with [data] and returns the response.
  ///
  /// If the device is offline, it stores the request locally and queues it for later execution.
  ///
  /// - [url]: The endpoint URL.
  /// - [data]: The data to be sent in the request body.
  /// - [queryParameters]: Optional query parameters.
  Future<Response<T>> delete<T extends Identifiable>(String url, T data,
      {Map<String, dynamic>? queryParameters}) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    if (await connectivityService.isConnected()) {
      try {
        Response<dynamic> response = await dio.delete(url,
            data: registryEntry.toJson(data), queryParameters: queryParameters);
        T result = registryEntry.fromJson(response.data);
        await localStorage.removeData<T>(data.id);
        return _dioResponse<T>(result, response);
      } catch (e) {
        await localStorage.storeRequest(url, 'DELETE', queryParameters, data);
        await localStorage.updateCachedData<T>(data);
        return Response<T>(
          data: data,
          requestOptions: RequestOptions(path: url),
          statusCode: 206,
          statusMessage: e.toString(),
        );
      }
    } else {
      await localStorage.storeRequest(url, 'DELETE', queryParameters, data);
      await localStorage.updateCachedData<T>(data);
      return Response<T>(
        requestOptions: RequestOptions(path: url),
        statusCode: 206,
        statusMessage: 'No connectivity',
      );
    }
  }

  @visibleForTesting
  Future<Response<T>> fetchFromLocalStorage<T extends Identifiable>(
      String url) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    List<T> cachedData = await localStorage.getData<T>();
    if (cachedData.isNotEmpty) {
      return Response<T>(
        data: cachedData.first,
        statusCode: 206,
        requestOptions: RequestOptions(path: url),
      );
    } else {
      return Response<T>(
        statusCode: 206,
        statusMessage: 'No data available',
        requestOptions: RequestOptions(path: url),
      );
    }
  }

  /// Sends a GET request to the specified [url] and returns the response as a list of items.
  ///
  /// If the device is offline, it fetches the data from local storage.
  ///
  /// - [url]: The endpoint URL.
  /// - [queryParameters]: Optional query parameters.
  Future<Response<List<T>>> getList<T extends Identifiable>(String url,
      {Map<String, dynamic>? queryParameters}) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    if (await connectivityService.isConnected()) {
      try {
        Response<dynamic> response =
            await dio.get(url, queryParameters: queryParameters);
        List<T> resultList = (response.data as List)
            .map((item) => registryEntry.fromJson(item) as T)
            .toList();
        await localStorage.storeDataList<T>(resultList);
        return _dioResponse<List<T>>(resultList, response);
      } catch (e) {
        return await fetchListFromLocalStorage<T>(url);
      }
    } else {
      return await fetchListFromLocalStorage<T>(url);
    }
  }

  /// Sends a POST request to the specified [url] with a list of items and returns the response.
  ///
  /// If the device is offline, it stores the request locally and queues it for later execution.
  ///
  /// - [url]: The endpoint URL.
  /// - [dataList]: The list of items to be sent in the request body.
  /// - [queryParameters]: Optional query parameters.
  Future<Response<List<T>>> postList<T extends Identifiable>(
      String url, List<T> dataList,
      {Map<String, dynamic>? queryParameters}) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    List<Response<T>> responses = [];
    if (await connectivityService.isConnected()) {
      for (var data in dataList) {
        try {
          Response<dynamic> response = await dio.post(url,
              data: registryEntry.toJson(data),
              queryParameters: queryParameters);
          if (response.data != null) {
            responses.addAll(response.data
                .map((item) => registryEntry.fromJson(item) as T)
                .map((e) => _dioResponse<T>(e, response))
                .toList());
          }
          await localStorage.storeData<T>(data);
        } catch (e) {
          responses.add(Response<T>(
            requestOptions: RequestOptions(path: url),
            statusCode: 206,
            statusMessage: e.toString(),
          ));
          await localStorage.storeRequest(url, 'POST', queryParameters, data);
        }
      }
    } else {
      for (var data in dataList) {
        responses.add(Response<T>(
          requestOptions: RequestOptions(path: url),
          statusCode: 206,
          statusMessage: 'No connectivity, operation queued',
        ));
        await localStorage.storeRequest(url, 'POST', queryParameters, data);
        await localStorage.storeData<T>(data);
      }
    }
    return Response<List<T>>(
      data: responses
          .where((response) => response.data != null)
          .map((response) => response.data!)
          .toList(),
      statusCode: responses.any((r) => r.statusCode != 200) ? 206 : 200,
      requestOptions: RequestOptions(path: url),
    );
  }

  /// Sends a PUT request to the specified [url] with a list of items and returns the response.
  ///
  /// If the device is offline, it stores the request locally and queues it for later execution.
  ///
  /// - [url]: The endpoint URL.
  /// - [dataList]: The list of items to be sent in the request body.
  /// - [queryParameters]: Optional query parameters.
  Future<Response<List<T>>> putList<T extends Identifiable>(
      String url, List<T> dataList,
      {Map<String, dynamic>? queryParameters}) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    List<Response<T>> responses = [];
    if (await connectivityService.isConnected()) {
      for (var data in dataList) {
        try {
          Response<dynamic> response = await dio.put(url,
              data: registryEntry.toJson(data),
              queryParameters: queryParameters);
          if (response.data != null) {
            responses.addAll(response.data
                .map((item) => registryEntry.fromJson(item) as T)
                .map((e) => _dioResponse<T>(e, response))
                .toList());
          }
          await localStorage.updateCachedData<T>(data);
        } catch (e) {
          responses.add(Response<T>(
            requestOptions: RequestOptions(path: url),
            statusCode: 206,
            statusMessage: e.toString(),
          ));
          await localStorage.storeRequest(url, 'PUT', queryParameters, data);
          await localStorage.updateCachedData<T>(data);
        }
      }
    } else {
      for (var data in dataList) {
        responses.add(Response<T>(
          requestOptions: RequestOptions(path: url),
          statusCode: 206,
          statusMessage: 'No connectivity, operation queued',
        ));
        await localStorage.storeRequest(url, 'PUT', queryParameters, data);
        await localStorage.updateCachedData<T>(data);
      }
    }
    return Response<List<T>>(
      data: responses
          .where((response) => response.data != null)
          .map((response) => response.data!)
          .toList(),
      statusCode: responses.any((r) => r.statusCode != 200) ? 206 : 200,
      requestOptions: RequestOptions(path: url),
    );
  }

  /// Sends a DELETE request to the specified [url] with a list of items and returns the response.
  ///
  /// If the device is offline, it stores the request locally and queues it for later execution.
  ///
  /// - [url]: The endpoint URL.
  /// - [dataList]: The list of items to be sent in the request body.
  /// - [queryParameters]: Optional query parameters.
  Future<Response<List<T>>> deleteList<T extends Identifiable>(
      String url, List<T> dataList,
      {Map<String, dynamic>? queryParameters}) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    List<Response<T>> responses = [];
    if (await connectivityService.isConnected()) {
      for (var data in dataList) {
        try {
          Response<dynamic> response = await dio.delete(url,
              data: registryEntry.toJson(data),
              queryParameters: queryParameters);
          if (response.data != null) {
            responses.addAll(response.data
                .map((item) => registryEntry.fromJson(item) as T)
                .map((e) => _dioResponse<T>(e, response))
                .toList());
          }
          await localStorage.removeData<T>(data.id);
        } catch (e) {
          responses.add(Response<T>(
            requestOptions: RequestOptions(path: url),
            statusCode: 206,
            statusMessage: e.toString(),
          ));
          await localStorage.storeRequest(url, 'DELETE', queryParameters, data);
          await localStorage.removeData<T>(data.id);
        }
      }
    } else {
      for (var data in dataList) {
        responses.add(Response<T>(
          requestOptions: RequestOptions(path: url),
          statusCode: 206,
          statusMessage: 'No connectivity, operation queued',
        ));
        await localStorage.storeRequest(url, 'DELETE', queryParameters, data);
        await localStorage.removeData<T>(data.id);
      }
    }
    return Response<List<T>>(
      data: responses
          .where((response) => response.data != null)
          .map((response) => response.data!)
          .toList(),
      statusCode: responses.any((r) => r.statusCode != 200) ? 206 : 200,
      requestOptions: RequestOptions(path: url),
    );
  }

  @visibleForTesting
  Future<Response<List<T>>> fetchListFromLocalStorage<T extends Identifiable>(
      String url) async {
    var registryEntry = TypeRegistry.get<T>();
    if (registryEntry == null) {
      throw Exception("Type ${T.toString()} is not registered.");
    }

    List<T> cachedData = await localStorage.getData<T>();
    if (cachedData.isNotEmpty) {
      return Response<List<T>>(
        data: cachedData,
        statusCode: 200,
        requestOptions: RequestOptions(path: url),
      );
    } else {
      return Response<List<T>>(
        data: [],
        statusCode: 206,
        statusMessage: 'No data available',
        requestOptions: RequestOptions(path: url),
      );
    }
  }

  /// Creates an interceptor to handle token injection and refresh.
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            await refreshToken();
            final token = await getToken();
            if (token != null) {
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
            }
            final clonedRequest = await dio.request(
              error.requestOptions.path,
              options: Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers,
              ),
              data: error.requestOptions.data,
              queryParameters: error.requestOptions.queryParameters,
            );
            return handler.resolve(clonedRequest);
          } catch (e) {
            return handler.next(error);
          }
        } else {
          return handler.next(error);
        }
      },
    );
  }

  /// Registers token handlers for obtaining and refreshing the token.
  void registerTokenHandlers({
    required Future<String?> Function() getTokenHandler,
    required Future<void> Function() refreshTokenHandler,
  }) {
    getToken = getTokenHandler;
    refreshToken = refreshTokenHandler;
  }

  /// Handles changes in network connectivity.
  ///
  /// Processes the request queue when connectivity is restored.
  ///
  /// - [isConnected]: The current connectivity status.
  @visibleForTesting
  void handleConnectivityChange(bool isConnected) {
    if (isConnected) {
      synchronizationService.processQueue().then((_) {
        // Optionally refresh data after processing the queue
      });
    }
  }

  /// Converts a Dio response to a [Response<T>].
  ///
  /// - [result]: The deserialized data.
  /// - [response]: The original Dio response.
  Response<T> _dioResponse<T>(result, Response<dynamic> response) {
    return Response<T>(
      data: result,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      headers: response.headers,
      requestOptions: response.requestOptions,
    );
  }
}
