import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../services/local_storage_service.dart';

class IsarManager {
  static Isar? _isarInstance;

  @visibleForTesting
  static void setIsarInstance(Isar instance) {
    _isarInstance = instance;
  }

  // Initialize Isar asynchronously before any call to `getIsarInstance`
  static Future<void> initializeIsar() async {
    if (_isarInstance == null) {
      final dir = await getApplicationDocumentsDirectory();
      _isarInstance = await Isar.open(
        [StoredRequestSchema, DataObjectSchema],
        directory: dir.path,
      );
    }
  }

  static Isar getIsarInstance() {
    if (_isarInstance == null) {
      throw Exception(
          'Isar instance not initialized. Call initializeIsar() first.');
    }
    return _isarInstance!;
  }
}
