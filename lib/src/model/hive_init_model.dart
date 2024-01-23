
import 'package:hive/hive.dart';

class HiveInitModel<T> {
  final TypeAdapter<T> typeAdapter;
  final int typeAdapterId;
  final String boxName;

  HiveInitModel(this.typeAdapter, this.typeAdapterId, this.boxName);
}