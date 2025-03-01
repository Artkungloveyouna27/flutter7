import 'package:flutter/material.dart';
import 'sql_helper.dart';

class ShowTask extends StatefulWidget {
  const ShowTask({super.key});

  @override
  State<ShowTask> createState() => _ShowTaskState();
}

class _ShowTaskState extends State<ShowTask> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void refreshTasks() async {
    final data = await SqlHelper.getTasks();
    setState(() {
      _tasks = data;
      _isLoading = false;
      print("...number of tasks: ${_tasks.length}");
    });
  }

  @override
  void initState() {
    super.initState();
    refreshTasks();
  }

  void showForm(int? id) {
    if (id != null) {
      final existingTask = _tasks.firstWhere((element) => element['id'] == id);
      titleController.text = existingTask['title'];
      descriptionController.text = existingTask['description'];
    } else {
      titleController.text = '';
      descriptionController.text = '';
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder:
          (_) => Container(
            padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty ||
                        descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter both title and description',
                          ),
                        ),
                      );
                      return;
                    }

                    if (id == null) {
                      await addTask();
                    } else {
                      await updateTask(id);
                    }

                    titleController.text = '';
                    descriptionController.text = '';
                    Navigator.of(context).pop(); // ปิด modal
                  },
                  child: Text(id == null ? 'Create New' : 'Update'),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> addTask() async {
    await SqlHelper.insertTask(
      titleController.text,
      descriptionController.text,
    );
    setState(() {
      refreshTasks();
    });
  }

  Future<void> updateTask(int id) async {
    await SqlHelper.updateTask(
      id,
      titleController.text,
      descriptionController.text,
    );
    setState(() {
      refreshTasks();
    });
  }

  void deleteTask(int id) async {
    await SqlHelper.deleteTask(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully deleted a task!')),
    );
    setState(() {
      refreshTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Management')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showForm(null), // เปิดฟอร์มสร้าง Task ใหม่
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tasks.isEmpty
              ? const Center(
                child: Text(
                  'No tasks available',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder:
                    (context, index) => Card(
                      color: Colors.amber,
                      margin: const EdgeInsets.all(15),
                      child: ListTile(
                        title: Text(_tasks[index]['title']),
                        subtitle: Text(_tasks[index]['description']),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => showForm(_tasks[index]['id']),
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed:
                                    () => deleteTask(_tasks[index]['id']),
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ),
    );
  }
}
