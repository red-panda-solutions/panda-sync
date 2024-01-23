import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:panda_sync/src/service/local_storage_service.dart';

import '../mocks.mocks.dart';

void main() {
  group('LocalStorageService', () {
    late LocalStorageService<String> service;
    late MockBox<String> mockBox;

    setUp(() {
      mockBox = MockBox<String>();
      service = LocalStorageService<String>(mockBox);
    });

    test('get should return an item', () {
      when(mockBox.get('key')).thenReturn('value');
      expect(service.get('key'), 'value');
    });

    test('getList should return all items', () {
      when(mockBox.values).thenReturn(['value1', 'value2']);
      expect(service.getList(), ['value1', 'value2']);
    });

    test('post should add an item', () async {
      await service.post('key', 'value');
      verify(mockBox.put('key', 'value')).called(1);
    });

    test('put should update an item', () async {
      await service.put('key', 'new value');
      verify(mockBox.put('key', 'new value')).called(1);
    });

    test('delete should remove an item', () async {
      await service.delete('key');
      verify(mockBox.delete('key')).called(1);
    });

    // Additional tests as needed
  });
}
