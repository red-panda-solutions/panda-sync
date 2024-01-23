import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:panda_sync/src/model/request.dart';
import 'package:panda_sync/src/service/sync_manager.dart';

import '../../model/user.dart';
import '../mocks.mocks.dart';

void main() {
  group('SyncManager', () {
    late SyncManager<User> syncManager;
    late MockLocalStorageService<User> mockLocalStorageService;
    late MockRemoteStorageService<User> mockRemoteStorageService;
    late MockQueueManager mockQueueManager;

    setUp(() {
      mockLocalStorageService = MockLocalStorageService();
      mockRemoteStorageService = MockRemoteStorageService();
      mockQueueManager = MockQueueManager();
      syncManager = SyncManager<User>(
        localStorageService: mockLocalStorageService,
        remoteStorageService: mockRemoteStorageService,
        queueManager: mockQueueManager,
      );
    });

    test('sync should process and update local storage for GET requests', () async {
      var request = Request(url: 'users/1', httpMethod: HttpMethod.get);
      var user = User(id: '1', name: 'John Doe');
      final responses = [false, true];
      when(mockQueueManager.isQueueEmpty()).thenAnswer((_) => responses.removeAt(0));
      when(mockQueueManager.pop()).thenReturn(request);
      when(mockRemoteStorageService.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => user);

      await syncManager.sync();

      verify(mockQueueManager.pop()).called(1);
      verify(mockRemoteStorageService.get('users/1', queryParameters: null)).called(1);
      verifyNever(mockLocalStorageService.post('user1', user));
    });

    test('sync should process and update local storage for POST requests', () async {
      var newUser = User(id: '2', name: 'Jane Doe');
      final responses = [false, true];
      var request = Request(url: 'users', httpMethod: HttpMethod.post, data: newUser.toJson());
      when(mockQueueManager.isQueueEmpty()).thenAnswer((_) => responses.removeAt(0));
      when(mockQueueManager.pop()).thenReturn(request);
      when(mockRemoteStorageService.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => newUser);

      await syncManager.sync();

      verify(mockQueueManager.pop()).called(1);
      verify(mockRemoteStorageService.post('users', data: newUser.toJson())).called(1);
    });

    test('sync should process and update local storage for PUT requests', () async {
      var updatedUser = User(id: '1', name: 'John Updated');
      final responses = [false, true];
      var request = Request(url: 'users/1', httpMethod: HttpMethod.put, data: updatedUser.toJson());
      when(mockQueueManager.isQueueEmpty()).thenAnswer((_) => responses.removeAt(0));
      when(mockQueueManager.pop()).thenReturn(request);
      when(mockRemoteStorageService.put(any, data: anyNamed('data')))
          .thenAnswer((_) async => updatedUser);

      await syncManager.sync();

      verify(mockQueueManager.pop()).called(1);
      verify(mockRemoteStorageService.put('users/1', data: updatedUser.toJson())).called(1);
    });

    test('sync should process and update local storage for DELETE requests', () async {
      var request = Request(url: 'users/1', httpMethod: HttpMethod.delete);
      var user = User(id: '1', name: 'John Doe');
      final responses = [false, true];
      when(mockQueueManager.isQueueEmpty()).thenAnswer((_) => responses.removeAt(0));
      when(mockQueueManager.pop()).thenReturn(request);
      when(mockRemoteStorageService.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => user);

      await syncManager.sync();

      verify(mockQueueManager.pop()).called(1);
      verify(mockRemoteStorageService.delete('users/1', data: null)).called(1);
    });
  });
}
