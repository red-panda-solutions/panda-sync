import 'package:panda_sync/src/utils/isar_manager.dart';

class OfflineFirstLocalStorageInit {
  static Future<void> initialize() async {
    await IsarManager.initializeIsar();
  }
}