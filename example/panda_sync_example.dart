
import 'package:dio/dio.dart';
import 'package:panda_sync/panda_sync.dart';

class TodoService {
  static final TodoService _instance = TodoService._internal();
  static final OfflineFirstClient offlineFirstClient =
  OfflineFirstClient(); // Instance of OfflineFirstClient

  factory TodoService() {
    return _instance;
  }

  TodoService._internal();

  Future<List<Task>> getAllTasks() async {
    try {
      // Fetch all tasks using OfflineFirstClient and handle deserialization
      Response<List<Task>> response = await offlineFirstClient.getList<Task>(
          'http://10.0.2.2:8080/api/tasks'); // Deserialization function

      return response.data!;
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<Task> getTaskById(int id) async {
    try {
      // Fetch a single task by ID using OfflineFirstClient
      Response<Task> response = await offlineFirstClient.get<Task>(
          'http://10.0.2.2:8080/api/tasks/$id'); // Deserialization function

      return response.data!;
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      // Create a new task using OfflineFirstClient
      var postResponse = await offlineFirstClient.post<Task>(
          'http://10.0.2.2:8080/api/tasks', // API endpoint
          task);
      return postResponse.data!;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      // Update a task using OfflineFirstClient
      var putResponse = await offlineFirstClient.put<Task>(
          'http://10.0.2.2:8080/api/tasks/${task.id}',
          // Constructed endpoint with task ID
          task);
      return putResponse.data!;
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      // Get the task before deletion to ensure it can be serialized
      Task taskToDelete = await getTaskById(id);
      // Delete a task using OfflineFirstClient
      await offlineFirstClient.delete<Task>(
          'http://10.0.2.2:8080/api/tasks/$id',
          // Constructed endpoint with task ID
          taskToDelete); // Serialization function
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}


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


Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  title: json['title'] as String,
  priority: json['priority'] as String,
  status: (json['status'] as num).toInt(),
  date:
  json['date'] == null ? null : DateTime.parse(json['date'] as String),
  id: (json['id'] as num?)?.toInt(),
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'date': instance.date.toIso8601String(),
  'priority': instance.priority,
  'status': instance.status,
};
