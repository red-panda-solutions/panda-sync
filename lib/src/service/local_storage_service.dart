import 'package:hive/hive.dart';

class LocalStorageService<T> {
  final Box<T> box;

  LocalStorageService(this.box);

  T? get(String key) {
    return box.get(key);
  }

  List<T> getList() {
    return box.values.toList();
  }

  Future<void> post(String key, T item) async {
    await box.put(key, item);
  }

  Future<void> put(String key, T item) async {
    await box.put(key, item);
  }

  Future<void> delete(String key) async {
    await box.delete(key);
  }
}
