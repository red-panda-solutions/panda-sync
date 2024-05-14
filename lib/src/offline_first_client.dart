import 'package:dio/dio.dart';
import 'package:panda_sync/src/services/connectivity_service.dart';
import 'package:panda_sync/src/services/local_storage_service.dart';
import 'package:panda_sync/src/services/synchronization_service.dart';
import 'package:panda_sync/src/utils/isar_manager.dart';

import '../panda_sync.dart';

class OfflineFirstClient {
  static final OfflineFirstClient _instance =
      OfflineFirstClient._createInstance();
  final Dio dio;
  final LocalStorageService localStorage;
  final ConnectivityService connectivityService;
  final SynchronizationService synchronizationService;

  factory OfflineFirstClient() => _instance;

  OfflineFirstClient._(this.dio, this.localStorage, this.connectivityService,
      this.synchronizationService) {
    connectivityService.connectivityStream.listen(_handleConnectivityChange);
  }

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

  Future<Response<T>> get<T extends Identifiable>(String url, Function fromJson,
      {Map<String, dynamic>? queryParameters}) async {
    if (await connectivityService.isConnected()) {
      try {
        Response<dynamic> response =
            await dio.get(url, queryParameters: queryParameters);
        T result = fromJson(response.data);
        await localStorage.storeData<T>(result);
        return Response<T>(
          data: result,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage,
          headers: response.headers,
          requestOptions: response.requestOptions,
        );
      } catch (e) {
        return await _fetchFromLocalStorage<T>(url, fromJson);
      }
    } else {
      return await _fetchFromLocalStorage<T>(url, fromJson);
    }
  }

  Future<Response<T>> post<T extends Identifiable>(
      String url, T data, Function toJson,
      {Map<String, dynamic>? queryParameters}) async {
    if (await connectivityService.isConnected()) {
      try {
        Response<T> response = await dio.post(url,
            data: toJson(data), queryParameters: queryParameters);
        await localStorage.storeData<T>(data);
        return response;
      } catch (e) {
        await localStorage.storeRequest(
            url, 'POST', queryParameters, toJson(data));
        await localStorage.updateCachedData<T>(data);
        return Response<T>(
          requestOptions: RequestOptions(path: url),
          statusCode: 206,
          statusMessage: e.toString(),
        );
      }
    } else {
      await localStorage.storeRequest(
          url, 'POST', queryParameters, toJson(data));
      await localStorage.updateCachedData<T>(data);
      return Response<T>(
        requestOptions: RequestOptions(path: url),
        statusCode: 206,
        statusMessage: 'No connectivity',
      );
    }
  }

  Future<Response<T>> put<T extends Identifiable>(
      String url, T data, Function toJson,
      {Map<String, dynamic>? queryParameters}) async {
    if (await connectivityService.isConnected()) {
      try {
        Response<T> response = await dio.put(url,
            data: toJson(data), queryParameters: queryParameters);
        await localStorage.updateCachedData<T>(data);
        return response;
      } catch (e) {
        await localStorage.storeRequest(
            url, 'PUT', queryParameters, toJson(data));
        await localStorage.updateCachedData<T>(data);
        return Response<T>(
          data: data,
          requestOptions: RequestOptions(path: url),
          statusCode: 206,
          statusMessage: e.toString(),
        );
      }
    } else {
      await localStorage.storeRequest(
          url, 'PUT', queryParameters, toJson(data));
      await localStorage.updateCachedData<T>(data);
      return Response<T>(
        data: data,
        requestOptions: RequestOptions(path: url),
        statusCode: 206,
        statusMessage: 'No connectivity',
      );
    }
  }

  Future<Response<T>> delete<T extends Identifiable>(
      String url, T data, Function toJson,
      {Map<String, dynamic>? queryParameters}) async {
    if (await connectivityService.isConnected()) {
      try {
        Response<T> response = await dio.delete(url,
            data: toJson(data), queryParameters: queryParameters);
        await localStorage.removeData<T>(T.toString(), data.id);
        return response;
      } catch (e) {
        await localStorage.storeRequest(
            url, 'DELETE', queryParameters, toJson(data));
        await localStorage.updateCachedData<T>(data);
        return Response<T>(
          data: data,
          requestOptions: RequestOptions(path: url),
          statusCode: 206,
          statusMessage: e.toString(),
        );
      }
    } else {
      await localStorage.storeRequest(
          url, 'DELETE', queryParameters, toJson(data));
      await localStorage.updateCachedData<T>(data);
      return Response<T>(
        requestOptions: RequestOptions(path: url),
        statusCode: 206,
        statusMessage: 'No connectivity',
      );
    }
  }

  Future<Response<T>> _fetchFromLocalStorage<T extends Identifiable>(
      String url, Function fromJson) async {
    List<T> cachedData = await localStorage.getData<T>(T.toString(), fromJson);
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

  Future<Response<List<T>>> getList<T extends Identifiable>(
      String url, Function fromJson,
      {Map<String, dynamic>? queryParameters}) async {
    if (await connectivityService.isConnected()) {
      try {
        Response<dynamic> response =
            await dio.get(url, queryParameters: queryParameters);
        List<T> resultList =
            (response.data as List).map((item) => fromJson(item) as T).toList();
        await localStorage.storeDataList<T>(resultList);
        return Response<List<T>>(
          data: resultList,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage,
          headers: response.headers,
          requestOptions: response.requestOptions,
        );
      } catch (e) {
        return await _fetchListFromLocalStorage<T>(url, fromJson);
      }
    } else {
      return await _fetchListFromLocalStorage<T>(url, fromJson);
    }
  }

  Future<Response<List<T>>> postList<T extends Identifiable>(
      String url, List<T> dataList, Function toJson,
      {Map<String, dynamic>? queryParameters}) async {
    List<Response<T>> responses = [];
    if (await connectivityService.isConnected()) {
      for (var data in dataList) {
        try {
          Response<T> response = await dio.post(url,
              data: toJson(data), queryParameters: queryParameters);
          responses.add(response);
          await localStorage.storeData<T>(data);
        } catch (e) {
          responses.add(Response<T>(
            requestOptions: RequestOptions(path: url),
            statusCode: 206,
            statusMessage: e.toString(),
          ));
          await localStorage.storeRequest(
              url, 'POST', queryParameters, toJson(data));
        }
      }
    } else {
      for (var data in dataList) {
        responses.add(Response<T>(
          requestOptions: RequestOptions(path: url),
          statusCode: 206,
          statusMessage: 'No connectivity, operation queued',
        ));
        await localStorage.storeRequest(
            url, 'POST', queryParameters, toJson(data));
        await localStorage.storeData<T>(data);
      }
    }
    return Response<List<T>>(
      data: responses.map((response) => response.data!).toList(),
      statusCode: responses.any((r) => r.statusCode != 200) ? 500 : 200,
      requestOptions: RequestOptions(path: url),
    );
  }

  Future<Response<List<T>>> putList<T extends Identifiable>(
      String url, List<T> dataList, Function toJson,
      {Map<String, dynamic>? queryParameters}) async {
    List<Response<T>> responses = [];
    if (await connectivityService.isConnected()) {
      for (var data in dataList) {
        try {
          Response<T> response = await dio.put(url,
              data: toJson(data), queryParameters: queryParameters);
          responses.add(response);
          await localStorage.updateCachedData<T>(data);
        } catch (e) {
          responses.add(Response<T>(
            requestOptions: RequestOptions(path: url),
            statusCode: 206,
            statusMessage: e.toString(),
          ));
          await localStorage.storeRequest(
              url, 'PUT', queryParameters, toJson(data));
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
        await localStorage.storeRequest(
            url, 'PUT', queryParameters, toJson(data));
        await localStorage.updateCachedData<T>(data);
      }
    }
    return Response<List<T>>(
      data: responses.map((response) => response.data!).toList(),
      statusCode: responses.any((r) => r.statusCode != 200) ? 500 : 200,
      requestOptions: RequestOptions(path: url),
    );
  }

  Future<Response<List<T>>> deleteList<T extends Identifiable>(
      String url, List<T> dataList, Function toJson,
      {Map<String, dynamic>? queryParameters}) async {
    List<Response<T>> responses = [];
    if (await connectivityService.isConnected()) {
      for (var data in dataList) {
        try {
          Response<T> response = await dio.delete(url,
              data: toJson(data), queryParameters: queryParameters);
          responses.add(response);
          await localStorage.removeData<T>(T.toString(), data.id);
        } catch (e) {
          responses.add(Response<T>(
            requestOptions: RequestOptions(path: url),
            statusCode: 206,
            statusMessage: e.toString(),
          ));
          await localStorage.storeRequest(
              url, 'DELETE', queryParameters, toJson(data));
          await localStorage.removeData<T>(T.toString(), data.id);
        }
      }
    } else {
      for (var data in dataList) {
        responses.add(Response<T>(
          requestOptions: RequestOptions(path: url),
          statusCode: 206,
          statusMessage: 'No connectivity, operation queued',
        ));
        await localStorage.storeRequest(
            url, 'DELETE', queryParameters, toJson(data));
        await localStorage.removeData<T>(T.toString(), data.id);
      }
    }
    return Response<List<T>>(
      data: responses.map((response) => response.data!).toList(),
      statusCode: responses.any((r) => r.statusCode != 200) ? 500 : 200,
      requestOptions: RequestOptions(path: url),
    );
  }

  Future<Response<List<T>>> _fetchListFromLocalStorage<T extends Identifiable>(
      String url, Function fromJson) async {
    List<T> cachedData = await localStorage.getData<T>(T.toString(), fromJson);
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

  void _handleConnectivityChange(bool isConnected) {
    if (isConnected) {
      synchronizationService.processQueue().then((_) {
        // Optionally refresh data after processing the queue
      });
    }
  }
}
