import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:panda_sync/src/model/request.dart';
import 'package:panda_sync/src/service/local_storage_service.dart';
import 'package:panda_sync/src/service/queue_manager.dart';
import 'package:panda_sync/src/service/remote_storage_service.dart';
import 'package:panda_sync/src/service/sync_manager.dart';

typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

class OfflineFirstClient<T> {
  late final RemoteStorageService<T> _remoteStorageService;
  late final LocalStorageService<T> _localStorageService;
  late final SyncManager<T> _syncManager;
  late final QueueManager _queueManager;
  final JsonFactory<T> fromJson;

  OfflineFirstClient(
      {required String boxName,
      required String apiBaseUrl,
      required this.fromJson}) {
    _remoteStorageService = RemoteStorageService(
        dio: GetIt.instance.get<Dio>(), fromJson: fromJson);
    _localStorageService = LocalStorageService(Hive.box(boxName));
  }

  Future<List<T>> getAll(String url) async {
    try {
      return await _remoteStorageService.getList(url);
    } catch (e) {
      return _localStorageService.getList();
    }
  }

  Future<T> getById(String url, String id) async {
    try {
      return await _remoteStorageService.get(url);
    } catch (e) {
      // Handle offline scenario, fetch from local storage
      return Future.value(_localStorageService.get(id));
    }
  }

  Future<void> post(
      String url, String id, Map<String, dynamic> queryParams, T item) async {
    try {
      await _remoteStorageService.post(url, data: item); // URL?
    } catch (e) {
      var request = Request(
          url: url, httpMethod: HttpMethod.post); // Construct a POST request
      _queueManager.push(request);
      _localStorageService.post(id, item);
    }
    _syncManager.sync();
  }

  Future<void> put(
      String url, String id, Map<String, dynamic> queryParams, T item) async {
    try {
      await _remoteStorageService.put(url, data: item);
    } catch (e) {
      // Handle offline scenario, queue the request and update locally
      var request = Request(
          url: url, httpMethod: HttpMethod.put); // Construct a PUT request
      _queueManager.push(request);
      _localStorageService.put(id, item);
    }
    _syncManager.sync();
  }

  Future<void> delete(
      String url, String id, Map<String, dynamic> queryParams) async {
    try {
      await _remoteStorageService.delete(id);
    } catch (e) {
      // Handle offline scenario, queue the request and remove from local
      var request = Request(url: url, httpMethod: HttpMethod.delete);
      _queueManager.push(request);
      _localStorageService.delete(id);
    }
    _syncManager.sync();
  }
}
