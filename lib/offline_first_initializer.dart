
import 'package:panda_sync/src/service/setup/dio_config.dart';
import 'package:panda_sync/src/service/setup/hive_config.dart';

class OfflineFirstSetup {
  final HiveConfig hiveConfig;
  final DioConfig dioConfig;

  OfflineFirstSetup({required this.hiveConfig, required this.dioConfig});

  void initialize() {
    hiveConfig.initialize();
    dioConfig.initialize();
  }
}
