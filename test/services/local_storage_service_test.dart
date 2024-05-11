import 'package:isar/isar.dart';
import 'package:mockito/mockito.dart';
import 'package:panda_sync/offline_first_lib.dart';
import 'package:test/test.dart';

import '../mocks/panda_sync.mocks.mocks.dart';

void main() {
  group('LocalStorageService', () {
    late MockIsar mockIsar;
    late MockIsarCollection<StoredRequest> mockStoredRequests;
    late LocalStorageService service;

    setUp(() {
      mockIsar = MockIsar();
      mockStoredRequests = MockIsarCollection<StoredRequest>();

      // Using the extension method to return the mocked collection
      when(mockIsar.collection<StoredRequest>()).thenReturn(mockStoredRequests);

      // Assuming IsarManager provides a static method to set the instance
      IsarManager.setIsarInstance(
          mockIsar); // This method needs to be implemented if not existing

      service = LocalStorageService(mockIsar);
    });

    test('storeRequest should add a request to the database', () async {
      await service.storeRequest(
          'https://example.com', 'GET', {'key': 'value'}, {'data': 'test'});
      verify(mockStoredRequests.put(any)).called(1);
    });

    test('getAllStoredRequests should return all requests', () async {
      when(mockStoredRequests.where().findAll())
          .thenAnswer((_) async => [StoredRequest()]);
      final requests = await service.getAllStoredRequests();
      expect(requests, isA<List<StoredRequest>>());
      verify(mockStoredRequests.where().findAll()).called(1);
    });

    test('deleteStoredRequest should remove a request from the database',
        () async {
      await service.deleteStoredRequest(1);
      verify(mockStoredRequests.delete(1)).called(1);
    });
  });
}
