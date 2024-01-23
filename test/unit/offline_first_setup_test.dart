import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:panda_sync/offline_first_initializer.dart';

import 'mocks.mocks.dart';

void main() {
  group('OfflineFirstSetup', () {
    test('should initialize Hive and Dio with provided configurations', () {
      // Create mock configurations
      var mockHiveConfig = MockHiveConfig();
      var mockDioConfig = MockDioConfig();
      when(mockHiveConfig.initialize()).thenAnswer((_) async => Future.value());
      when(mockDioConfig.initialize()).thenAnswer((_) async => Future.value());

      // Create an instance of OfflineFirstSetup
      var setup = OfflineFirstSetup(hiveConfig: mockHiveConfig, dioConfig: mockDioConfig);

      // Call initialize
      setup.initialize();

      // Verify that Hive and Dio configurations are initialized
      verify(mockHiveConfig.initialize()).called(1);
      verify(mockDioConfig.initialize()).called(1);
    });
  });
}
