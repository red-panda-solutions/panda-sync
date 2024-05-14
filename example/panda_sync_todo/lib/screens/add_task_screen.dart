import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:panda_sync_todo/model/task_model.dart';

import '../service/todo_local_service.dart';
import 'home_screen.dart';

class AddTaskScreen extends StatefulWidget {
  final Function updateTaskList;
  final Task task;

  const AddTaskScreen(this.updateTaskList, this.task, {super.key});

  @override
  AddTaskScreenState createState() => AddTaskScreenState();
}

class AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String? _priority;
  DateTime _date = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();

    _title = widget.task.title;
    _date = widget.task.date;
    _priority = widget.task.priority;

    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  _delete() {
    Navigator.pop(context);
    widget.updateTaskList();
    Fluttertoast.showToast(msg: "Task Deleted");
  }

  _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Print the task details for debugging
      if (kDebugMode) {
        print('$_title, $_date, $_priority');
      }

      // Check if we are updating an existing task or creating a new one
      bool isUpdating = widget.task.id != 0;

      Task task = Task(
        id: widget.task.id,
        title: _title,
        date: _date,
        priority: _priority!,
        status: widget.task.status,
      );

      if (isUpdating) {
        // Update the task
        Fluttertoast.showToast(msg: "Task Updated");
      } else {
        // Set the default status for new tasks
        task.status = 0;
        Fluttertoast.showToast(msg: "Task Added");
      }

      // Save or update the task using the remote API
      if (isUpdating) {
        TodoService().updateTask(task).then((updatedTask) {
          widget.updateTaskList();
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        }).catchError((error) {
          Fluttertoast.showToast(msg: "Failed to update task: $error");
        });
      } else {
        TodoService().createTask(task).then((newTask) {
          widget.updateTaskList();
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        }).catchError((error) {
          Fluttertoast.showToast(msg: "Failed to add task: $error");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context)),
        title: Row(children: [
          Text(
            widget.task == null ? 'Add Task' : 'Update Task',
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 20.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ]),
        actions: [
          IconButton(
              icon: const Icon(
                Icons.info_outline,
                color: Colors.black,
              ),
              onPressed: () {}),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          style: const TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: const TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (input) => input!.trim().isEmpty
                              ? 'Please enter a task title'
                              : null,
                          onSaved: (input) => _title = input!,
                          initialValue: _title,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          style: const TextStyle(fontSize: 18.0),
                          onTap: _handleDatePicker,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            labelStyle: const TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: DropdownButtonFormField(
                          isDense: true,
                          icon: const Icon(Icons.arrow_drop_down_circle),
                          iconSize: 22.0,
                          iconEnabledColor: Theme.of(context).primaryColor,
                          items: _priorities.map((String priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                ),
                              ),
                            );
                          }).toList(),
                          style: const TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            labelStyle: const TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (input) => _priority == null
                              ? 'Please select a priority level'
                              : null,
                          onChanged: (value) {
                            setState(() {
                              _priority = value;
                            });
                          },
                          value: _priority,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        // ignore: deprecated_member_use
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text(
                            widget.task == null ? 'Add' : 'Update',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ),
                      widget.task != null
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 0.0),
                              height: 60.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: ElevatedButton(
                                onPressed: _delete,
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
