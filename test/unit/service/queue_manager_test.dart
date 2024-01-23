import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:panda_sync/src/model/request.dart';
import 'package:panda_sync/src/service/queue_manager.dart';

import '../mocks.mocks.dart';

void main() {
  group('QueueManager', () {
    late QueueManager queueManager;
    late Box<Request> mockBox;

    setUp(() {
      mockBox = MockBox();
      queueManager = QueueManager(mockBox);
    });

    test('should add requests to the queue', () {
      var request =
          Request(url: 'https://api.example.com', httpMethod: HttpMethod.post);
      when(mockBox.add(request))
          .thenAnswer((_) async => 0); // Mock Hive box add

      queueManager.push(request);

      // Verify that the request was added to the box
      verify(mockBox.add(request)).called(1);
    });

    test('should pop request from the queue if box not empty', () {
      var expected =
          Request(url: 'https://api.example.com', httpMethod: HttpMethod.post);
      when(mockBox.isNotEmpty).thenReturn(true);
      when(mockBox.getAt(0)).thenReturn(expected);

      var actual = queueManager.pop();

      // Verify that the request was added to the box
      verify(mockBox.isNotEmpty).called(1);
      verify(mockBox.getAt(0)).called(1);
      verify(mockBox.deleteAt(0)).called(1);
      expect(actual, expected);
    });

    test('should return null from the queue if box empty', () {
      when(mockBox.isNotEmpty).thenReturn(false);

      var shouldBeNull = queueManager.pop();

      // Verify that the request was added to the box
      verify(mockBox.isNotEmpty).called(1);
      verifyNever(mockBox.getAt(0));
      verifyNever(mockBox.deleteAt(0));
      expect(shouldBeNull, null);
    });

    test('should return if queue is empty', () {
      when(mockBox.isEmpty).thenReturn(true);

      var isQueueEmpty = queueManager.isQueueEmpty();

      // Verify that the request was added to the box
      verify(mockBox.isEmpty).called(1);
      expect(isQueueEmpty, true);
    });
  });
}
