<!-- markdownlint-disable MD033 MD041 -->
<p align="center" style="margin-bottom: 0px;">
  <img src="logo.png" width="200px">
</p>

<h1 align="center" style="margin-top: 0px; font-size: 4em;">Panda Sync</h1>

[![tests](https://img.shields.io/github/actions/workflow/status/red-panda-solutions/panda-sync/dart.yml?branch=main)](https://github.com/red-panda-solutions/panda-sync/actions) [![pub.dev](https://img.shields.io/pub/v/panda_sync?label=pub.dev&labelColor=333940&logo=dart)](https://pub.dev/packages/panda_sync) [![license](https://img.shields.io/github/license/red-panda-solutions/panda-sync?color=%23007A88&labelColor=333940&logo=mit)](https://github.com/red-panda-solutions/panda-sync/blob/master/LICENSE)

# panda_sync

`panda_sync` is a Dart library designed to facilitate the development of offline-first applications
using Flutter. It provides seamless data synchronization between local storage and a remote server,
ensuring your app remains functional even without internet connectivity. The

## Features

- **Offline-First Functionality**: Automatically handles data synchronization when the device is
  online.
- **Local Storage with Isar**: Utilizes Isar, a high-performance NoSQL database, for local data
  storage.
- **Network Request Management**: Uses Dio for making network requests and managing connectivity
  states.
- **Type Registration**: Enforces type registration for data serialization and deserialization.
- **Automatic Retry**: Automatically retries failed network requests when the device regains
  connectivity.
- **Customizable**: Allows customization of request handling and data processing.

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml

dependencies:
  panda_sync: ^1.0.0 # Add the latest version
```

## Usage

### Step 1: Initialize Local Storage

Before using the library, initialize Isar core:

```dart

import 'package:panda_sync/panda_sync.dart';

void main() async {
  await OfflineFirstLocalStorageInit.initialize();
  runApp(MyApp());
}
```

## Step 2: Extend your data models with `Identifieble` and implement static `fromJson` and `toJson` methods.

```dart
import 'package:panda_sync/panda_sync.dart';

import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

//This example uses json_serializable but this is not mandatory
@JsonSerializable()
class Task extends Identifiable {
  @override
  int id;

  ...

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  static Map<String, dynamic> taskToJson(Task task) => _$TaskToJson(task);
}

```

### Step 3: Register the types your app will use:

```dart

import 'package:panda_sync/panda_sync.dart';
import 'model/task_model.dart'; // Import your model

void main() async {
  await OfflineFirstLocalStorageInit.initialize();

  TypeRegistry.register<Task>('TaskBox', Task.taskToJson, Task.fromJson);

  runApp(MyApp());
}

```

### Step 4: Create an Instance of `OfflineFirstClient`

Create an instance of OfflineFirstClient:

```dart

final OfflineFirstClient offlineFirstClient =
OfflineFirstClient();
```

### Step 5: Use the `OfflineFirstClient` as you would use any other Http client

Here's how to use the library in a service class:

```dart
import 'package:dio/dio.dart';
import 'package:panda_sync/panda_sync.dart';
import 'model/task_model.dart';

class TodoService {
  static final TodoService _instance = TodoService._internal();
  static final OfflineFirstClient offlineFirstClient =
  OfflineFirstClient();

  factory TodoService() {
    return _instance;
  }

  TodoService._internal();

  Future<List<Task>> getAllTasks() async {
    try {
      Response<List<Task>> response = await offlineFirstClient.getList<Task>(
          'http://10.0.2.2:8080/api/tasks');
      return response.data!;
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<Task> getTaskById(int id) async {
    try {
      Response<Task> response = await offlineFirstClient.get<Task>(
          'http://10.0.2.2:8080/api/tasks/$id');
      return response.data!;
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      var postResponse = await offlineFirstClient.post<Task>(
          'http://10.0.2.2:8080/api/tasks', task);
      return postResponse.data!;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      var putResponse = await offlineFirstClient.put<Task>(
          'http://10.0.2.2:8080/api/tasks/${task.id}', task);
      return putResponse.data!;
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      Task taskToDelete = await getTaskById(id);

      await offlineFirstClient.delete<Task>('http://10.0.2.2:8080/api/tasks/$id', taskToDelete);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
```

# API Documentation

- **OfflineFirstClient**

    - `OfflineFirstClient()`: Creates an instance of **OfflineFirstClient**.
    - `Future<Response<T>> get<T extends Identifiable>(String url, {Map<String, dynamic>? queryParameters}):`
      Makes a GET request.
    - `Future<Response<T>> post<T extends Identifiable>(String url, T data, {Map<String, dynamic>? queryParameters}):`
      Makes a POST request.
    - `Future<Response<T>> put<T extends Identifiable>(String url, T data, {Map<String, dynamic>? queryParameters}):`
      Makes a PUT request.
    - `Future<Response<T>> delete<T extends Identifiable>(String url, T data, {Map<String, dynamic>? queryParameters}):`
      Makes a DELETE request.
    - `Future<Response<List<T>>> getList<T extends Identifiable>(String url, {Map<String, dynamic>? queryParameters}):`
      Makes a GET request for a list of items.
    - `Future<Response<List<T>>> postList<T extends Identifiable>(String url, List<T> dataList, {Map<String, dynamic>? queryParameters}):`
      Makes a POST request for a list of items.
    - `Future<Response<List<T>>> putList<T extends Identifiable>(String url, List<T> dataList, {Map<String, dynamic>? queryParameters}):`
      Makes a PUT request for a list of items.
    - `Future<Response<List<T>>> deleteList<T extends Identifiable>(String url, List<T> dataList, {Map<String, dynamic>? queryParameters}):`
      Makes a DELETE request for a list of items.

# Contributing

We welcome contributions! Please follow these steps to contribute:

    1. Fork the repository.
    2. Create a new branch (`git checkout -b my-feature-branch`).
    3. Make your changes.
    4. Commit your changes (`git commit -am 'Add new feature'`).
    5. Push to the branch (git push origin my-feature-branch).
    6. Create a Pull Request.

# License

This project is licensed under the MIT License - see the LICENSE file for details.

# Acknowledgements

- [Isar Database](https://github.com/isar/isar)
- [Dio HTTP Client](https://github.com/cfug/dio)
- [Connectivity Plus](https://github.com/fluttercommunity/plus_plugins/tree/main/packages/connectivity_plus/connectivity_plus)

# Contact

For any questions or suggestions, feel free to open an issue or contact any maintainer.
