import 'package:panda_sync/panda_sync.dart';

import 'package:json_annotation/json_annotation.dart';


part 'task_model.g.dart';

@JsonSerializable()
class Task extends Identifiable{
  @override
  int id;
  String title;
  late DateTime date;
  String priority;
  late int status; // 0 - Incomplete, 1 - Complete

  Task(
      {required this.title,
        required this.priority,
        required this.status,
        DateTime? date,
        int? id})
      : date = date ?? DateTime.now(),
        id = id ?? 0;

  Task.withId(
      {required this.id,
        required this.title,
        required this.priority,
        required this.status,
        DateTime? date})
      : date = date ?? DateTime.now();

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  static Map<String, dynamic> taskToJson(Task task) => _$TaskToJson(task);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
