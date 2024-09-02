import 'package:flutter/material.dart';
import 'package:frontend/provider/TaskModel.dart';
import 'package:frontend/view/SubtasksView.dart';
import 'package:provider/provider.dart';
import 'package:frontend/library/globals.dart' as globals;

class ListTasksWidget extends StatefulWidget {
  final String? projectId;

  const ListTasksWidget({Key? key, this.projectId}) : super(key: key);

  @override
  _ListTasksWidgetState createState() => _ListTasksWidgetState();
}

class _ListTasksWidgetState extends State<ListTasksWidget> {
  bool showDone = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
         actions: [
          IconButton(
            icon: Icon(showDone ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                showDone = !showDone;
              });
            },
          ),
        ],
      ),
      body: Consumer<TaskModel>(
        builder: (context, model, child) {
          // ignore: unused_local_variable
          final filteredTasks = model.tasks[widget.projectId] ?? [];
           final tasksToShow = filteredTasks.where((task) =>
              showDone ? true : !task.status).toList();

          return ListView.builder(
            itemCount:tasksToShow.length,
            itemBuilder: (BuildContext context, int index) {
              final task = tasksToShow[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 173, 226, 249),
                    border: Border.all(color: Color(0xFFE2E2E2)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(task.title),
                    subtitle: Text(
                      'Developers: ${task.developerNames.join(', ')}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    leading: Checkbox(
                      value: task.status,
                      onChanged: (bool? value) {
                        model.markAsDone(widget.projectId!, index);
                      },
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubtasksView(task: task),
                              ),
                            );
                          },
                          icon: Icon(Icons.subdirectory_arrow_right),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            // Navigate to Add Subtask view (implement this route)
                            Navigator.pushNamed(context, 'addSubtask');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: UniqueKey(),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, 'addTasks');
        },
      ),
    );
  }
}