import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Future<List<Task>> getTasks() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Task'));
    final response = await query.query();
    if (response.success) {
      if(response.results!= null){
        return response.results!.map((e) => Task.fromParseObject(e)).toList();
      }
      return [];
    } else {
      print('Error fetching tasks: ${response.error?.message}');
      return [];
    }
  }

  Future<void> deleteTask(String taskId) async {
    final parseObject = ParseObject('Task')..objectId = taskId;
    final response = await parseObject.delete();
    if (response.success) {
      print('Task deleted');
      _loadTasks();
    } else {
      print('Error deleting task: ${response.error?.message}');
    }
  }

  Future<bool> addTask(String title, String status, String description, DateTime dueDate) async {
    final task = ParseObject('Task')
      ..set('title', title)
      ..set('status', status)
      ..set('description', description)
      ..set('dueDate', dueDate);
    final response = await task.save();

    if (response.success) {
      print('Task added successfully');
      return true;
    } else {
      print('Error adding task: ${response.error?.message}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Column(
        children: [
          Expanded(
            child: _tasks.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No data found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text("${formatDate(task.dueDate)}\n${task.status}"),
                  onTap: () {
                    // Handle task update
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deleteTask(task.id);
                      _loadTasks(); // Refresh task list
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                showAddTaskDialog(context, (title, status, description, dueDate) {
                  // Call addTask() with these values
                  addTask(title, status, description, dueDate).then((success) {
                    if (success) {
                      _loadTasks(); // Refresh the task list
                    }
                  });
                });
              },
              child: const Text('Add Task'),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> showAddTaskDialog(BuildContext context, Function(String, String, String, DateTime) onAddTask) async {
    final _titleController = TextEditingController();
    final _statusController = TextEditingController();
    final _descriptionController = TextEditingController();
    DateTime? _selectedDueDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _statusController,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDueDate == null
                                ? 'No Due Date Selected'
                                : 'Due Date: ${formatDate(_selectedDueDate!)}',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _selectedDueDate = pickedDate;
                              });
                            }
                          },
                          child: Text('Select Date'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty &&
                        _statusController.text.isNotEmpty &&
                        _descriptionController.text.isNotEmpty &&
                        _selectedDueDate != null) {
                      onAddTask(
                        _titleController.text,
                        _statusController.text,
                        _descriptionController.text,
                        _selectedDueDate!,
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all fields')),
                      );
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String formatDate(DateTime dueDate) {
    try {
      // Format the DateTime to DD:MM:YYYY
      return DateFormat('dd/MM/yyyy').format(dueDate);
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid date';
    }
  }


}