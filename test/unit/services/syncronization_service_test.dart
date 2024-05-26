import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:panda_sync/panda_sync.dart';
import 'package:panda_sync/src/services/local_storage_service.dart';
import 'package:panda_sync/src/services/synchronization_service.dart';
import 'package:test/test.dart';

import '../mocks/panda_sync.mocks.mocks.dart';

class MockIdentifiable extends Mock implements Identifiable {
  @override
  int get id => 1;
}

void main() {
  late MockLocalStorageService mockLocalStorageService;
  late MockDio mockDio;
  late SynchronizationService synchronizationService;

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    mockDio = MockDio();
    synchronizationService =
        SynchronizationService(mockLocalStorageService, dioClient: mockDio);

    // Register mock Identifiable type
    TypeRegistry.register<MockIdentifiable>(
      'MockIdentifiableBox',
      (data) => {'id': data.id},
      (json) => MockIdentifiable(),
    );
  });

  group('SynchronizationService', () {
    test('processQueue should process the queue and delete successful requests',
        () async {
      final storedRequests = [
        StoredRequest()
          ..id = 1
          ..url = 'https://example.com'
          ..method = 'POST'
          ..typeBoxName = 'MockIdentifiableBox'
          ..queryParams = '{}'
          ..body = json.encode({'id': 1}),
      ];

      when(mockLocalStorageService.getAllStoredRequests())
          .thenAnswer((_) async => storedRequests);
      when(mockDio.post(any,
              data: anyNamed('data'),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''), statusCode: 200));

      await synchronizationService.processQueue();

      verify(mockLocalStorageService.deleteStoredRequest(1)).called(1);
    });

    test('processQueue should not delete failed requests', () async {
      final storedRequests = [
        StoredRequest()
          ..id = 1
          ..url = 'https://example.com'
          ..method = 'POST'
          ..typeBoxName = 'MockIdentifiableBox'
          ..queryParams = '{}'
          ..body = json.encode({'id': 1}),
      ];

      when(mockLocalStorageService.getAllStoredRequests())
          .thenAnswer((_) async => storedRequests);
      when(mockDio.post(any,
              data: anyNamed('data'),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''), statusCode: 500));

      await synchronizationService.processQueue();

      verifyNever(mockLocalStorageService.deleteStoredRequest(1));
    });

    test('executeStoredRequest should execute POST request correctly',
        () async {
      final storedRequest = StoredRequest()
        ..url = 'https://example.com'
        ..method = 'POST'
        ..typeBoxName = 'MockIdentifiableBox'
        ..queryParams = '{}'
        ..body = json.encode({'id': 1});

      when(mockDio.post(any,
              data: anyNamed('data'),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''), statusCode: 200));

      final response =
          await synchronizationService.executeStoredRequest(storedRequest);

      expect(response.statusCode, 200);
      verify(mockDio.post(
        storedRequest.url,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });

    test('executeStoredRequest should execute GET request correctly', () async {
      final storedRequest = StoredRequest()
        ..url = 'https://example.com'
        ..method = 'GET'
        ..body = '{}'
        ..queryParams = '{}'
        ..typeBoxName = 'MockIdentifiableBox';

      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''), statusCode: 200));

      final response =
          await synchronizationService.executeStoredRequest(storedRequest);

      expect(response.statusCode, 200);
      verify(mockDio.get(
        storedRequest.url,
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });

    test('executeStoredRequest should execute PUT request correctly', () async {
      final storedRequest = StoredRequest()
        ..url = 'https://example.com'
        ..method = 'PUT'
        ..typeBoxName = 'MockIdentifiableBox'
        ..queryParams = '{}'
        ..body = json.encode({'id': 1});

      when(mockDio.put(any,
              data: anyNamed('data'),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''), statusCode: 200));

      final response =
          await synchronizationService.executeStoredRequest(storedRequest);

      expect(response.statusCode, 200);
      verify(mockDio.put(
        storedRequest.url,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });

    test('executeStoredRequest should execute DELETE request correctly',
        () async {
      final storedRequest = StoredRequest()
        ..url = 'https://example.com'
        ..method = 'DELETE'
        ..typeBoxName = 'MockIdentifiableBox'
        ..queryParams = '{}'
        ..body = json.encode({'id': 1});

      when(mockDio.delete(any,
              data: anyNamed('data'),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''), statusCode: 200));

      final response =
          await synchronizationService.executeStoredRequest(storedRequest);

      expect(response.statusCode, 200);
      verify(mockDio.delete(
        storedRequest.url,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });

    test(
        'executeStoredRequest should throw an exception for unsupported HTTP method',
        () async {
      final storedRequest = StoredRequest()
        ..url = 'https://example.com'
        ..method = 'PATCH' // Unsupported method
        ..typeBoxName = 'MockIdentifiableBox'
        ..queryParams = '{}'
        ..body = json.encode({'id': 1});

      expect(
        () => synchronizationService.executeStoredRequest(storedRequest),
        throwsA(isA<Exception>().having((e) => e.toString(), 'description',
            contains('Unsupported HTTP method'))),
      );
    });
  });
}
