import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/TaskModel.dart';

class ProjectTasksView extends StatelessWidget {
  //final Project project;
  final String projectId;

  const ProjectTasksView({Key? key, required this.projectId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskModel = context.watch<TaskModel>();
    // ignore: unused_local_variable
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
                subtitle: Text(task.developerNames.join(', ')),
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
    );
  }
}
