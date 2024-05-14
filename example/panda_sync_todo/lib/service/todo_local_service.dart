import 'package:dio/dio.dart';
import 'package:panda_sync/panda_sync.dart';

import '../model/task_model.dart';

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
          'http://10.0.2.2:8080/api/tasks', // API endpoint
          Task.fromJson); // Deserialization function

      return response.data!;
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<Task> getTaskById(int id) async {
    try {
      // Fetch a single task by ID using OfflineFirstClient
      Response<Task> response = await offlineFirstClient.get<Task>(
          'http://10.0.2.2:8080/api/tasks/$id',
          // Constructed endpoint with task ID
          Task.fromJson); // Deserialization function

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
          task, // Task data
          Task.taskToJson); // Serialization function
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
          task, // Task data
          Task.taskToJson); // Serialization function
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
          taskToDelete, // Task data to delete
          Task.taskToJson); // Serialization function
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
