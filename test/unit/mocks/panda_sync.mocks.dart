import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:mockito/annotations.dart';
import 'package:panda_sync/src/services/connectivity_service.dart';
import 'package:panda_sync/src/services/local_storage_service.dart';
import 'package:panda_sync/src/services/synchronization_service.dart';

@GenerateMocks([
  Connectivity,
  Isar,
  IsarCollection,
  QueryBuilder,
  Query,
  LocalStorageService,
  Dio,
  SynchronizationService,
  ConnectivityService,
  HttpClientAdapter
])
void main() {}
