import 'package:hive/hive.dart';
import 'package:panda_sync/src/model/request.dart';

class HiveConfig {
  final HiveInterface hive;
  final String boxName;

  HiveConfig({required this.hive, required this.boxName});

  initialize() async {
    if (!Hive.isAdapterRegistered(999)) {
      Hive.registerAdapter(RequestAdapter());
    }
    if (!Hive.isBoxOpen(requestBoxName)) {
      await hive.openBox<Request>(requestBoxName);
    }
  }
}
