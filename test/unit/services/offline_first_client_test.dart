import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:panda_sync/panda_sync.dart';
import 'package:panda_sync/src/services/connectivity_service.dart';
import 'package:panda_sync/src/services/local_storage_service.dart';
import 'package:panda_sync/src/services/synchronization_service.dart';
import 'package:panda_sync/src/utils/isar_manager.dart';
import 'package:test/test.dart';

import '../mocks/panda_sync.mocks.mocks.dart';

class MockIdentifiable extends Mock implements Identifiable {
  @override
  int get id => 1;
}

void main() {
  late MockDio mockDio;
  late MockLocalStorageService mockLocalStorageService;
  late MockConnectivityService mockConnectivityService;
  late MockSynchronizationService mockSynchronizationService;
  late OfflineFirstClient offlineFirstClient;

  setUp(() {
    mockDio = MockDio();
    mockLocalStorageService = MockLocalStorageService();
    mockConnectivityService = MockConnectivityService();
    mockSynchronizationService = MockSynchronizationService();

    offlineFirstClient = OfflineFirstClient.createForTest(
      mockDio,
      mockLocalStorageService,
      mockConnectivityService,
      mockSynchronizationService,
    );

    // Register mock Identifiable type
    TypeRegistry.register<MockIdentifiable>(
      'MockIdentifiableBox',
      (data) => {'id': data.id},
      (json) => MockIdentifiable(),
    );
  });

  group('OfflineFirstClient', () {
    test('get should fetch data from the network if connected', () async {
      final data = MockIdentifiable();
      final responseData = {'id': 1};

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              statusCode: 200,
              data: responseData,
              requestOptions: RequestOptions(path: '')));
      when(mockLocalStorageService.storeData<MockIdentifiable>(any))
          .thenAnswer((_) async => {});

      final response =
          await offlineFirstClient.get<MockIdentifiable>('https://example.com');

      expect(response.statusCode, 200);
      expect(response.data, isA<MockIdentifiable>());
      verify(mockLocalStorageService.storeData<MockIdentifiable>(any))
          .called(1);
    });

    test('get should fetch data from local storage if not connected', () async {
      final data = MockIdentifiable();
      final responseData = {'id': 1};

      when(mockConnectivityService.isConnected())
          .thenAnswer((_) async => false);
      when(mockLocalStorageService.getData<MockIdentifiable>())
          .thenAnswer((_) async => [data]);

      final response =
          await offlineFirstClient.get<MockIdentifiable>('https://example.com');

      expect(response.statusCode, 206);
      expect(response.data, isA<MockIdentifiable>());
    });

    test('post should send data to the network if connected', () async {
      final data = MockIdentifiable();

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockDio.post(any,
              data: anyNamed('data'),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              statusCode: 200, requestOptions: RequestOptions(path: '')));

      final response =
          await offlineFirstClient.post('https://example.com', data);

      expect(response.statusCode, 200);
      verify(mockLocalStorageService.storeData(data)).called(1);
    });

    test('post should store request locally if not connected', () async {
      final data = MockIdentifiable();

      when(mockConnectivityService.isConnected())
          .thenAnswer((_) async => false);
      when(mockLocalStorageService.storeRequest<MockIdentifiable>(
              any, any, any, any))
          .thenAnswer((_) async => {});

      final response =
          await offlineFirstClient.post('https://example.com', data);

      expect(response.statusCode, 206);
      verify(mockLocalStorageService.storeRequest<MockIdentifiable>(
              any, any, any, any))
          .called(1);
    });

    test('put should update data on the network if connected', () async {
      final data = MockIdentifiable();

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockDio.put(any,
              data: anyNamed('data'),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              statusCode: 200, requestOptions: RequestOptions(path: '')));

      final response =
          await offlineFirstClient.put('https://example.com', data);

      expect(response.statusCode, 200);
      verify(mockLocalStorageService.updateCachedData(data)).called(1);
    });

    test('put should store request locally if not connected', () async {
      final data = MockIdentifiable();

      when(mockConnectivityService.isConnected())
          .thenAnswer((_) async => false);
      when(mockLocalStorageService.storeRequest<MockIdentifiable>(
              any, any, any, any))
          .thenAnswer((_) async => {});

      final response =
          await offlineFirstClient.put('https://example.com', data);

      expect(response.statusCode, 206);
      verify(mockLocalStorageService.storeRequest<MockIdentifiable>(
              any, any, any, any))
          .called(1);
    });

    test('delete should remove data from the network if connected', () async {
      final data = MockIdentifiable();

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockDio.delete(any,
              data: anyNamed('data'),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              statusCode: 200, requestOptions: RequestOptions(path: '')));

      final response =
          await offlineFirstClient.delete('https://example.com', data);

      expect(response.statusCode, 200);
      verify(mockLocalStorageService.removeData(data.id)).called(1);
    });

    test('delete should store request locally if not connected', () async {
      final data = MockIdentifiable();

      when(mockConnectivityService.isConnected())
          .thenAnswer((_) async => false);
      when(mockLocalStorageService.storeRequest<MockIdentifiable>(
              any, any, any, any))
          .thenAnswer((_) async => {});

      final response =
          await offlineFirstClient.delete('https://example.com', data);

      expect(response.statusCode, 206);
      verify(mockLocalStorageService.storeRequest<MockIdentifiable>(
              any, any, any, any))
          .called(1);
    });

    test('getList should fetch list from the network if connected', () async {
      final dataList = [MockIdentifiable()];
      final responseData = [
        {'id': 1}
      ];

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              statusCode: 200,
              data: responseData,
              requestOptions: RequestOptions(path: '')));
      when(mockLocalStorageService.storeDataList(any))
          .thenAnswer((_) async => {});

      final response = await offlineFirstClient
          .getList<MockIdentifiable>('https://example.com');

      expect(response.statusCode, 200);
      expect(response.data, isA<List<MockIdentifiable>>());
      verify(mockLocalStorageService.storeDataList(any)).called(1);
    });

    test('getList should fetch list from local storage if not connected',
        () async {
      final dataList = [MockIdentifiable()];

      when(mockConnectivityService.isConnected())
          .thenAnswer((_) async => false);
      when(mockLocalStorageService.getData<MockIdentifiable>())
          .thenAnswer((_) async => dataList);

      final response = await offlineFirstClient
          .getList<MockIdentifiable>('https://example.com');

      expect(response.statusCode, 200);
      expect(response.data, isA<List<MockIdentifiable>>());
    });

    test('postList should send list to the network if connected', () async {
      final dataList = [MockIdentifiable()];

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockDio.post(any,
              data: anyNamed('data'),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              statusCode: 200, requestOptions: RequestOptions(path: '')));

      final response =
          await offlineFirstClient.postList('https://example.com', dataList);

      expect(response.statusCode, 200);
      verify(mockLocalStorageService.storeData<MockIdentifiable>(any))
          .called(1);
    });

    test('postList should store requests locally if not connected', () async {
      final dataList = [MockIdentifiable()];

      when(mockConnectivityService.isConnected())
          .thenAnswer((_) async => false);
      when(mockLocalStorageService.storeRequest<MockIdentifiable>(
              any, any, any, any))
          .thenAnswer((_) async => {});

      final response =
          await offlineFirstClient.postList('https://example.com', dataList);

      expect(response.statusCode, 206);
      verify(mockLocalStorageService.storeRequest<MockIdentifiable>(
              any, any, any, any))
          .called(dataList.length);
    });

    test('putList should update list on the network if connected', () async {
      final dataList = [MockIdentifiable()];

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockDio.put(any,
              data: anyNamed('data'),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              statusCode: 200, requestOptions: RequestOptions(path: '')));

      final response =
          await offlineFirstClient.putList('https://example.com', dataList);

      expect(response.statusCode, 200);
      verify(mockLocalStorageService.updateCachedData<MockIdentifiable>(any))
          .called(1);
    });

    test('putList should store requests locally if not connected', () async {
      final dataList = [MockIdentifiable()];

      when(mockConnectivityService.isConnected())
          .thenAnswer((_) async => false);
      when(mockLocalStorageService.storeRequest<MockIdentifiable>(
              any, any, any, any))
          .thenAnswer((_) async => {});

      final response =
          await offlineFirstClient.putList('https://example.com', dataList);

      expect(response.statusCode, 206);
      verify(mockLocalStorageService.storeRequest<MockIdentifiable>(
              any, any, any, any))
          .called(dataList.length);
    });

    test('deleteList should remove list from the network if connected',
        () async {
      final dataList = [MockIdentifiable()];

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockDio.delete(any,
              data: anyNamed('data'),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              statusCode: 200, requestOptions: RequestOptions(path: '')));

      final response =
          await offlineFirstClient.deleteList('https://example.com', dataList);

      expect(response.statusCode, 200);
      verify(mockLocalStorageService.removeData(any)).called(1);
    });

    test('deleteList should store requests locally if not connected', () async {
      final dataList = [MockIdentifiable()];

      when(mockConnectivityService.isConnected())
          .thenAnswer((_) async => false);
      when(mockLocalStorageService.storeRequest<MockIdentifiable>(
              any, any, any, any))
          .thenAnswer((_) async => {});

      final response =
          await offlineFirstClient.deleteList('https://example.com', dataList);

      expect(response.statusCode, 206);
      verify(mockLocalStorageService.storeRequest<MockIdentifiable>(
              any, any, any, any))
          .called(dataList.length);
    });

    test('_fetchFromLocalStorage should return data from local storage',
        () async {
      final data = MockIdentifiable();

      when(mockLocalStorageService.getData<MockIdentifiable>())
          .thenAnswer((_) async => [data]);

      final response = await offlineFirstClient
          .fetchFromLocalStorage<MockIdentifiable>('https://example.com');

      expect(response.statusCode, 206);
      expect(response.data, isA<MockIdentifiable>());
    });

    test('_fetchListFromLocalStorage should return list from local storage',
        () async {
      final dataList = [MockIdentifiable()];

      when(mockLocalStorageService.getData<MockIdentifiable>())
          .thenAnswer((_) async => dataList);

      final response = await offlineFirstClient
          .fetchListFromLocalStorage<MockIdentifiable>('https://example.com');

      expect(response.statusCode, 200);
      expect(response.data, isA<List<MockIdentifiable>>());
    });

    test('_handleConnectivityChange should process the queue when connected',
        () async {
      when(mockSynchronizationService.processQueue())
          .thenAnswer((_) async => {});

      offlineFirstClient.handleConnectivityChange(true);

      verify(mockSynchronizationService.processQueue()).called(1);
    });
  });
}
