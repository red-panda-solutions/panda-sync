import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:panda_sync/src/service/remote_storage_service.dart';

import '../../model/user.dart';
import '../mocks.mocks.dart';

void main() {
  group('RemoteStorageService', () {
    late RemoteStorageService<User> service;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      service = RemoteStorageService<User>(
        dio: mockDio,
        fromJson: (json) => User.fromJson(json),
      );
    });

    test('get should return a user.dart', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
        data: {'id': '1', 'name': 'John Doe'},
        requestOptions: RequestOptions(path: ''),
      ));

      var user = await service.get('users/1');
      expect(user, isA<User>());
      expect(user.id, '1');
    });

    test('getList should return a list of Users', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
        data: [
          {'id': '1', 'name': 'John Doe'},
          {'id': '2', 'name': 'Jane Doe'}
        ],
        requestOptions: RequestOptions(path: ''),
      ));

      var users = await service.getList('users');
      expect(users, isA<List<User>>());
      expect(users.length, 2);
      expect(users[0].id, '1');
    });

    // Additional tests for post, put, delete methods
    // Include tests for error scenarios and edge cases
    // Test for POST method
    test('post should send data and receive a user.dart', () async {
      final userData = {'id': '1', 'name': 'John Doe'};
      when(mockDio.post(any, data: anyNamed('data'), options: anyNamed('options')))
          .thenAnswer((_) async => Response(
        data: userData,
        requestOptions: RequestOptions(path: ''),
      ));

      var user = await service.post('users', data: userData);
      expect(user, isA<User>());
      expect(user.id, '1');
    });

    // Test for PUT method
    test('put should send data and receive a user.dart', () async {
      final userData = {'id': '1', 'name': 'Jane Doe'};
      when(mockDio.put(any, data: anyNamed('data'), options: anyNamed('options')))
          .thenAnswer((_) async => Response(
        data: userData,
        requestOptions: RequestOptions(path: ''),
      ));

      var user = await service.put('users/1', data: userData);
      expect(user, isA<User>());
      expect(user.name, 'Jane Doe');
    });

    // Test for DELETE method
    test('delete should remove data', () async {
      when(mockDio.delete('users/1', data: anyNamed('data'), options: anyNamed('options')))
          .thenAnswer((_) async => Response<User>(
        data: null,
        requestOptions: RequestOptions(path: ''),
        statusCode: 204, // No content
      ));

      Response response = await service.delete('users/1');
      expect(response.statusCode, 204);
    });
  });
}
