import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';

import '../services/local_storage_service.dart';

class IsarManager {
  static Isar? _isarInstance;


  @visibleForTesting
  static void setIsarInstance(Isar instance) {
    _isarInstance = instance;
  }

  static Future<Isar> getIsarInstance() async {
    if (_isarInstance == null) {
      final dir = await getApplicationDocumentsDirectory();
      _isarInstance = await Isar.open(
        [StoredRequestSchema],
        directory: dir.path,
      );
    }
    return _isarInstance!;
  }
}