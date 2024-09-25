import 'package:flutter/material.dart';
import 'package:frontend/model/Project.dart';
import 'package:frontend/provider/NotificationModel.dart';
import 'package:frontend/provider/ProjectModel.dart';
import 'package:frontend/provider/TaskModel.dart';
import 'package:frontend/view/SubtasksView.dart';
import 'package:provider/provider.dart';
import 'package:frontend/model/Notification.dart' as CustomNotification;
import 'package:frontend/provider/DeveloperModel.dart';

class ListTasksWidget extends StatefulWidget {
  final String? projectId;
  const ListTasksWidget({Key? key, this.projectId}) : super(key: key);

  @override
  _ListTasksWidgetState createState() => _ListTasksWidgetState();
}

class _ListTasksWidgetState extends State<ListTasksWidget> {
  bool showDone = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectModel = Provider.of<ProjectModel>(context, listen: false);
      final taskModel = Provider.of<TaskModel>(context, listen: false);

      projectModel.fetchProjects().then((_) {
        final projectIds = projectModel.getProjectIds();
        taskModel.fetchTasksForAllProjects(projectIds);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId =
        Provider.of<DeveloperModel>(context, listen: false).user.idUtilisateur;
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
      body: Consumer2<ProjectModel, TaskModel>(
        builder: (context, projectModel, model, child) {
          final filteredTasks = widget.projectId != null
              ? model.getTasksByProject(widget.projectId!)
              : [];
          final tasksToShow = filteredTasks
              .where((task) => showDone ? true : !task.status)
              .toList();
          //print('Tasks for project ${widget.projectId}: ${tasksToShow.length}');

          final tasksByProject = model.tasksByProject;

          if (tasksByProject.isEmpty) {
            return Center(child: Text('No tasks available'));
          }

          return ListView.builder(
            itemCount: tasksByProject.length,
            itemBuilder: (BuildContext context, int index) {
              final projectId = tasksByProject.keys.elementAt(index);
              final projectTasks = tasksByProject[projectId]!
                  .where((task) => showDone ? true : !task.status)
                  .toList();
              final Project? project = projectModel.projects.firstWhere(
                (proj) => proj.projectId == projectId,
                orElse: () => Project(projectId, 'Unknown Project',
                    'No description available', [], [], null),
              );
              final projectName =
                  project != null ? project.title : 'Unknown Project';

              return ExpansionTile(
                title: Text('Project : $projectName'),
                children: projectTasks.map((task) {
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
                            setState(() {
                              model.markAsDone(
                                  projectId, projectTasks.indexOf(task));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Task "${task.title}" marked as Completed')),
                              );
                            });
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // To-Do button
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  task.isToDo = true;
                                  task.isInProgress = false;
                                  task.status = false;
                                  model.updateTask(task);

                                  CustomNotification.Notification
                                      newNotification =
                                      CustomNotification.Notification(
                                    id: UniqueKey().toString(),
                                    message:
                                        'Task "${task.title}" marked as To-Do',
                                    userId: userId,
                                    timestamp: DateTime.now(),
                                  );
                                  Provider.of<NotificationModel>(context,
                                          listen: false)
                                      .addNotification(userId,
                                          'Task "${task.title}" marked as To-Do');

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Task "${task.title}" marked as To-Do')),
                                  );
                                });
                              },
                              icon: Icon(Icons.assignment_late,
                                  color: task.isToDo
                                      ? Colors.orange
                                      : Colors.grey),
                            ),

                            // In Progress button
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  task.isToDo = false;
                                  task.isInProgress = true;
                                  task.status = false;
                                  model.updateTask(task);

                                  // Create a notification for In Progress status
                                  CustomNotification.Notification
                                      newNotification =
                                      CustomNotification.Notification(
                                    id: UniqueKey().toString(),
                                    message:
                                        'Task "${task.title}" is In Progress',
                                    userId: userId,
                                    timestamp: DateTime.now(),
                                  );
                                  Provider.of<NotificationModel>(context,
                                          listen: false)
                                      .addNotification(userId,
                                          'Task "${task.title}" marked as To-Do');

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Task "${task.title}" is In Progress')),
                                  );
                                });
                              },
                              icon: Icon(Icons.play_circle_fill,
                                  color: task.isInProgress
                                      ? Colors.orange
                                      : Colors.grey),
                            ),

                            // Completed button
                            IconButton(
                              icon: Icon(Icons.check_circle,
                                  color:
                                      task.status ? Colors.green : Colors.grey),
                              onPressed: () {
                                setState(() {
                                  task.isToDo = false;
                                  task.isInProgress = false;
                                  task.status = true;
                                  model.updateTask(task);

                                  // Create a notification for Completed status
                                  CustomNotification.Notification
                                      newNotification =
                                      CustomNotification.Notification(
                                    id: UniqueKey().toString(),
                                    message: 'Task "${task.title}" completed',
                                    userId: userId,
                                    timestamp: DateTime.now(),
                                  );
                                  Provider.of<NotificationModel>(context,
                                          listen: false)
                                      .addNotification(userId,
                                          'Task "${task.title}" marked as To-Do');

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Task "${task.title}" completed')),
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
