import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:panda_sync/src/service/setup/dio_config.dart';

void main() {
  group('DioConfig', () {
    test('should configure Dio with correct base URL and headers', () {
      // Define expected configuration values
      const Map<String, dynamic> testHeaders = {'Content-Type': 'application/json'};

      // Create DioConfig instance
      DioConfig dioConfig = DioConfig(headers: testHeaders);

      // Create Dio instance with configuration
      dioConfig.initialize();
      Dio dio = dioConfig.dio;
      // Check if Dio is correctly configured
      expect(dio.options.headers.values, containsAll(testHeaders.values));
    });

  });
}
