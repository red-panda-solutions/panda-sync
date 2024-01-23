import 'package:panda_sync/src/service/queue_manager.dart';
import 'package:panda_sync/src/service/remote_storage_service.dart';

import '../model/request.dart';
import 'local_storage_service.dart';

class SyncManager<T> {
  final LocalStorageService<T> localStorageService;
  final RemoteStorageService<T> remoteStorageService;
  final QueueManager queueManager;

  SyncManager({
    required this.localStorageService,
    required this.remoteStorageService,
    required this.queueManager,
  });

  void queueRequest(Request request) {
    queueManager.push(request);
  }

  Future<void> sync() async {
    while (!queueManager.isQueueEmpty()) {
      var request = queueManager.pop();
      if (request != null) {
        try {
          var response = await processRequest(request);
          //await localStorageService.post(request.key, response);
        } catch (e) {
          // Handle error - optionally re-queue the request
        }
      }
    }
  }

  Future<T> processRequest(Request request) async {
    switch (request.method) {
      case HttpMethod.get:
        return remoteStorageService.get(request.url, queryParameters: request.queryParameters);
      case HttpMethod.post:
        return remoteStorageService.post(request.url, data: request.data);
      case HttpMethod.put:
        return remoteStorageService.put(request.url, data: request.data);
      case HttpMethod.delete:
        await remoteStorageService.delete(request.url);
        return Future.value(null); // Assuming delete operations don't return a resource
      default:
        throw Exception('Unsupported HTTP method');
    }
  }
}
