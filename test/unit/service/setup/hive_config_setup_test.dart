import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:panda_sync/src/service/setup/hive_config.dart';

import '../../mocks.mocks.dart';


void main() {
  group('HiveConfig', () {
    late MockHiveInterface mockHive;
    late HiveConfig hiveConfig;

    setUp(() {
      mockHive = MockHiveInterface();
      hiveConfig = HiveConfig(hive: mockHive, boxName: 'testBox');
    });

    test('should initialize Hive and open specified box', () async {
      // Setup mock to return a MockBox when openBox is called
      when(mockHive.openBox('testBox')).thenAnswer((_) => Future.value(MockBox()));

      // Perform initialization
      await hiveConfig.initialize();

      // Verify that openBox is called with the correct box name
      verify(mockHive.openBox('testBox')).called(1);
    });

    // Additional tests for other aspects of HiveConfig can be added here
  });
}
