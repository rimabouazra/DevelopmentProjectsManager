import 'package:flutter/material.dart';
import 'package:frontend/view/AddTasksView.dart';
import 'package:provider/provider.dart';
import '../provider/TaskModel.dart';
import '../model/Project.dart';

class ProjectTasksView extends StatelessWidget {
  //final Project project;
  final String projectId;

  const ProjectTasksView({Key? key, required this.projectId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskModel = context.watch<TaskModel>();
    final tasks = taskModel.getTasksByProject(projectId);
    return Scaffold(
      body: Consumer<TaskModel>(
        builder: (context, taskModel, child) {
          final projectTasks = taskModel.getTasksByProject(projectId);

          return ListView.builder(
            itemCount: projectTasks.length,
            itemBuilder: (context, index) {
              final task = projectTasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.deadline.toString()),
                leading: Checkbox(
                  value: task.status,
                  onChanged: (bool? value) {
                    taskModel.markAsDone(projectId, index);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddTasksView(projectId:projectId),
          ));
        },
        child: Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }
}
