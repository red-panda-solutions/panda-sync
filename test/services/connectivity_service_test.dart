import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mockito/mockito.dart';
import 'package:panda_sync/src/services/connectivity_service.dart';
import 'package:test/test.dart';

import '../mocks/panda_sync.mocks.mocks.dart';

void main() {
  group('ConnectivityService', () {
    late ConnectivityService service;
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockConnectivity = MockConnectivity();
      service = ConnectivityService(connectivity: mockConnectivity);
    });

    test('should return true when there is connectivity', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.mobile);

      expect(await service.isConnected(), isTrue);
      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    test('should return false when there is no connectivity', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      expect(await service.isConnected(), isFalse);
      verify(mockConnectivity.checkConnectivity()).called(1);
    });
    test('should return true for mobile connectivity', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.mobile);
      expect(await service.isConnected(), isTrue);
    });

    test('should return true for WiFi connectivity', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      expect(await service.isConnected(), isTrue);
    });

    test('should return true for Ethernet connectivity', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.ethernet);
      expect(await service.isConnected(), isTrue);
    });

    test('should return false for no connectivity', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);
      expect(await service.isConnected(), isFalse);
    });

    // Testing the connectivityStream for transitions
    test('connectivityStream should emit correct values on status change',
        () async {
      when(mockConnectivity.onConnectivityChanged).thenAnswer(
        (_) => Stream.fromIterable([
          ConnectivityResult.mobile,
          ConnectivityResult.none,
          ConnectivityResult.wifi,
          ConnectivityResult.none,
        ]),
      );
      expect(
        service.connectivityStream,
        emitsInOrder([true, false, true, false]),
      );
    });
  });
}
