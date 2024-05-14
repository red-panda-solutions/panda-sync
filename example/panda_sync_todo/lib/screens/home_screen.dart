import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:panda_sync_todo/model/task_model.dart';
import 'package:panda_sync_todo/screens/add_task_screen.dart';
import 'package:panda_sync_todo/service/todo_local_service.dart';

import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Future<List<Task>> _taskList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = TodoService().getAllTasks();
    });
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: <Widget>[
          if (task.status == 0)
            ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: 18.0,
                  decoration: task.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(
                '${_dateFormatter.format(task.date)} • ${task.priority}',
                style: TextStyle(
                  fontSize: 15.0,
                  decoration: task.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              trailing: Checkbox(
                onChanged: (bool? value) async {
                  if (value == null) {
                    return; // Early exit if value is somehow null
                  }
                  task.status = value ? 1 : 0;
                  try {
                    Task updatedTask = await TodoService().updateTask(task);
                    Fluttertoast.showToast(
                        msg: "Task Updated ${updatedTask.id}");
                    _updateTaskList(); // This should refresh the list or state depending on your UI setup
                  } catch (e) {
                    Fluttertoast.showToast(msg: "Failed to update task: $e");
                  }
                },
                activeColor: Theme.of(context).primaryColor,
                value: task.status == 1,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddTaskScreen(_updateTaskList, task)),
              ),
            ),
          //Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      //onPopInvoked: onBackPressed,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          child: const Icon(Icons.add_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(
                  _updateTaskList,
                  Task(
                      id: 0,
                      title: '',
                      priority: 'Low',
                      status: 0,
                      date: DateTime.now())),
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
          leading: const IconButton(
              icon: Icon(
                Icons.calendar_today_outlined,
                color: Colors.grey,
              ),
              onPressed: null),
          title: const Row(
            children: [
              Text(
                "Task",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20.0,
                  fontWeight: FontWeight.normal,
                  letterSpacing: -1.2,
                ),
              ),
              Text(
                "Manager",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 20.0,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0,
                ),
              )
            ],
          ),
          centerTitle: false,
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.all(0),
              child: IconButton(
                  icon: const Icon(Icons.history_outlined),
                  iconSize: 25.0,
                  color: Colors.black,
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => HistoryScreen()))),
            ),
            Container(
              margin: const EdgeInsets.all(6.0),
              child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  iconSize: 25.0,
                  color: Colors.black,
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => Settings()))),
            )
          ],
        ),
        body: FutureBuilder(
          future: _taskList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final int completedTaskCount = snapshot.data!
                .where((Task task) => task.status == 0)
                .toList()
                .length;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              itemCount: 1 + snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin:
                              const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Color.fromRGBO(240, 240, 240, 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Center(
                            child: Text(
                              'You have [ $completedTaskCount ] pending task out of [ ${snapshot.data!.length} ]',
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
                return _buildTask(snapshot.data![index - 1]);
              },
            );
          },
        ),
      ),
    );
  }
}
