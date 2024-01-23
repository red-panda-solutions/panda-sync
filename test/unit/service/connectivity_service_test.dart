import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:panda_sync/src/service/connectivity_service.dart';

import '../mocks.mocks.dart';


void main() {
  group('ConnectivityService', () {
    late MockConnectivity mockConnectivity;
    late ConnectivityService service;

    setUp(() {
      mockConnectivity = MockConnectivity();
      service = ConnectivityService(connectivity: mockConnectivity);

      // Setup the mock stream
      Stream<ConnectivityResult> mockStream = Stream.fromIterable([
        ConnectivityResult.wifi,
        ConnectivityResult.none,
      ]);
      when(mockConnectivity.onConnectivityChanged).thenAnswer((_) => mockStream);
    });

    test('should emit connectivity changes', () async {
      // Collect emitted values
      final List<ConnectivityResult> emittedValues = [];
      final StreamSubscription<ConnectivityResult> subscription =
      service.onConnectivityChanged.listen(
        emittedValues.add,
      );

      // Wait for the stream to complete
      await Future.delayed(Duration.zero);
      await subscription.cancel();

      // Compare collected values with expected values
      expect(emittedValues, equals([ConnectivityResult.wifi, ConnectivityResult.none]));
    });
  });
}
