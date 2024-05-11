import 'package:dio/dio.dart';
import 'package:isar/isar.dart';

import 'connectivity_service.dart';
import '../utils/isar_manager.dart';
import 'local_storage_service.dart';
import 'synchronization_service.dart';

class OfflineFirstClient {
  static OfflineFirstClient? _instance;
  final Dio dio;
  final LocalStorageService localStorage;
  final ConnectivityService connectivityService;
  final SynchronizationService synchronizationService;

  OfflineFirstClient._(this.dio, this.localStorage, this.connectivityService,
      this.synchronizationService) {
    connectivityService.connectivityStream.listen(_handleConnectivityChange);
  }

  static Future<OfflineFirstClient> getInstance() async {
    if (_instance == null) {
      Isar isar = await IsarManager.getIsarInstance();
      LocalStorageService localStorage = LocalStorageService(isar);
      ConnectivityService connectivityService = ConnectivityService();
      SynchronizationService synchronizationService =
          SynchronizationService(localStorage);
      Dio dio = Dio();

      _instance = OfflineFirstClient._(
          dio, localStorage, connectivityService, synchronizationService);
    }
    return _instance!;
  }

  Future<Response<T>> get<T>(String url,
      {Map<String, dynamic>? queryParameters}) async {
    return _handleRequest<T>('GET', url, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String url,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _handleRequest<T>('POST', url,
        data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> put<T>(String url,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _handleRequest<T>('PUT', url,
        data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> delete<T>(String url,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _handleRequest<T>('DELETE', url,
        data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> _handleRequest<T>(String method, String url,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    if (await connectivityService.isConnected()) {
      try {
        Response<T> response = await dio.request<T>(url,
            data: data,
            queryParameters: queryParameters,
            options: Options(method: method));
        return response;
      } catch (e) {
        return Response<T>(
            requestOptions: RequestOptions(path: url),
            statusCode: 503); // Indicate service unavailable
      }
    } else {
      await localStorage.storeRequest(url, method, queryParameters, data);
      return Response<T>(
          requestOptions: RequestOptions(path: url),
          statusCode: 503); // Indicate service unavailable
    }
  }

  void _handleConnectivityChange(bool isConnected) {
    if (isConnected) {
      synchronizationService.processQueue();
    }
  }
}

//
// class OfflineFirstClient {
//   final Dio dio;
//   final LocalStorageService localStorage;
//   final ConnectivityService connectivityService;
//
//   OfflineFirstClient(this.dio, this.localStorage, this.connectivityService) {
//     connectivityService.connectivityStream.listen(_handleConnectivityChange);
//   }
//
//   Future<Response<T>> get<T>(String url,
//       {Map<String, dynamic>? queryParameters}) async {
//     if (await connectivityService.isConnected()) {
//       try {
//         var response = await dio.get<T>(url, queryParameters: queryParameters);
//         // Optionally store successful responses for future offline access
//         localStorage.storeRequest(url, 'GET', queryParameters, response.data);
//         return response;
//       } catch (e) {
//         // If online but the request fails, try to fetch cached data
//         var cachedResponse = await localStorage.getCachedResponse<T>(
//             url, 'GET', queryParameters);
//         if (cachedResponse != null) {
//           return Response<T>(
//             data: cachedResponse.data,
//             requestOptions: RequestOptions(path: url),
//             statusCode: 200, // Indicate that data comes from cache
//           );
//         }
//         rethrow;
//       }
//     } else {
//       // If offline, return cached data if available
//       var cachedResponse =
//           await localStorage.getCachedResponse<T>(url, 'GET', queryParameters);
//       if (cachedResponse != null) {
//         return Response<T>(
//           data: cachedResponse.data,
//           requestOptions: RequestOptions(path: url),
//           statusCode: 200, // Indicate that data comes from cache
//         );
//       }
//       return Response<T>(
//         data: null,
//         requestOptions: RequestOptions(path: url),
//         statusCode: 503, // Indicate service unavailable
//       );
//     }
//   }
//
//   Future<Response<T>> post<T>(String url,
//       {dynamic data, Map<String, dynamic>? queryParameters}) async {
//     if (await connectivityService.isConnected()) {
//       try {
//         var response = await dio.post<T>(url,
//             data: data, queryParameters: queryParameters);
//         // Optionally store successful responses for future offline access
//         localStorage.storeRequest(url, 'POST', queryParameters, data);
//         return response;
//       } catch (e) {
//         // If online but the request fails, try to fetch cached data
//         var cachedResponse = await localStorage.getCachedResponse<T>(
//             url, 'POST', queryParameters);
//         if (cachedResponse != null) {
//           return Response<T>(
//             data: cachedResponse.data,
//             requestOptions: RequestOptions(path: url),
//             statusCode: 200, // Indicate that data comes from cache
//           );
//         }
//         rethrow;
//       }
//     } else {
//       // If offline, store the request for later synchronization
//       await localStorage.storeRequest(url, 'POST', queryParameters, data);
//       return Response<T>(
//         data: null,
//         requestOptions: RequestOptions(path: url),
//         statusCode: 503, // Indicate service unavailable
//       );
//     }
//   }
//
//   Future<Response<T>> put<T>(String url,
//       {dynamic data, Map<String, dynamic>? queryParameters}) async {
//     if (await connectivityService.isConnected()) {
//       try {
//         var response =
//             await dio.put<T>(url, data: data, queryParameters: queryParameters);
//         // Optionally store successful responses for future offline access
//         localStorage.storeRequest(url, 'PUT', queryParameters, data);
//         return response;
//       } catch (e) {
//         // If online but the request fails, try to fetch cached data
//         var cachedResponse = await localStorage.getCachedResponse<T>(
//             url, 'PUT', queryParameters);
//         if (cachedResponse != null) {
//           return Response<T>(
//             data: cachedResponse.data,
//             requestOptions: RequestOptions(path: url),
//             statusCode: 200, // Indicate that data comes from cache
//           );
//         }
//         rethrow;
//       }
//     } else {
//       // If offline, store the request for later synchronization
//       await localStorage.storeRequest(url, 'PUT', queryParameters, data);
//       return Response<T>(
//         data: null,
//         requestOptions: RequestOptions(path: url),
//         statusCode: 503, // Indicate service unavailable
//       );
//     }
//   }
//
//   Future<Response<T>> delete<T>(String url,
//       {dynamic data, Map<String, dynamic>? queryParameters}) async {
//     if (await connectivityService.isConnected()) {
//       try {
//         var response = await dio.delete<T>(url,
//             data: data, queryParameters: queryParameters);
//         // Optionally store successful responses for future offline access
//         localStorage.storeRequest(url, 'DELETE', queryParameters, data);
//         return response;
//       } catch (e) {
//         // If online but the request fails, try to fetch cached data
//         var cachedResponse = await localStorage.getCachedResponse<T>(
//             url, 'DELETE', queryParameters);
//         if (cachedResponse != null) {
//           return Response<T>(
//             data: cachedResponse.data,
//             requestOptions: RequestOptions(path: url),
//             statusCode: 200, // Indicate that data comes from cache
//           );
//         }
//         rethrow;
//       }
//     } else {
//       // If offline, store the request for later synchronization
//       await localStorage.storeRequest(url, 'DELETE', queryParameters, data);
//       return Response<T>(
//         data: null,
//         requestOptions: RequestOptions(path: url),
//         statusCode: 503, // Indicate service unavailable
//       );
//     }
//   }
//
//   void _handleConnectivityChange(bool isConnected) {
//     if (isConnected) {
//       localStorage.processQueue();
//     }
//   }
// }
