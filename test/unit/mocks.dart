import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:hive/hive.dart';
import 'package:panda_sync/src/service/local_storage_service.dart';
import 'package:panda_sync/src/service/queue_manager.dart';
import 'package:panda_sync/src/service/remote_storage_service.dart';
import 'package:panda_sync/src/service/setup/dio_config.dart';
import 'package:panda_sync/src/service/setup/hive_config.dart';
import 'package:panda_sync/src/service/sync_manager.dart';

@GenerateMocks([
  Box,
  Connectivity,
  Dio,
  DioConfig,
  HiveConfig,
  HiveInterface,
  RemoteStorageService,
  LocalStorageService,
  QueueManager,
  SyncManager
])
void main() {}
