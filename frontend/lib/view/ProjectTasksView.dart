import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/TaskModel.dart';
import '../view/AddSubtaskView.dart';
import '../model/Task.dart';
import '../model/Subtask.dart'; 

class ProjectTasksView extends StatelessWidget {
  final String projectId;

  const ProjectTasksView({Key? key, required this.projectId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskModel = Provider.of<TaskModel>(context, listen: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!taskModel.tasksByProject.containsKey(projectId)|| taskModel.tasksByProject[projectId]!.isEmpty) {
        taskModel.fetchTasksForProject(projectId);
      }
    });

    final projectTasks = taskModel.getTasksByProject(projectId);

    return Scaffold(
      body: projectTasks.isEmpty
          ? Center(child: Text('No tasks available for this project'))
          : ListView.builder(
              itemCount: projectTasks.length,
              itemBuilder: (context, index) {
                final task = projectTasks[index];
                 return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  child: ExpansionTile(
                    title: Text(task.title),
                    subtitle: Text('Assigned Developers: ${task.developerNames.join(', ')}'),
                    leading: Checkbox(
                      value: task.status,
                      onChanged: (bool? value) {
                        taskModel.markAsDone(projectId, index);
                      },
                    ),
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: task.subtasks.length,
                        itemBuilder: (context, subtaskIndex) {
                          final subtask = task.subtasks[subtaskIndex];

                          return SubtaskTile(
                            task: task,
                            subtask: subtask,
                            onCommentAdded: (String text) {
                              taskModel.addCommentToSubtask(task, subtask, text);
                            },
                          );
                        },
                      ),
                      ListTile(
                        title: TextButton(
                          child: Text('Add Subtask'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddSubtaskView(task: task),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, 'addTasks', arguments: projectId);
        },
      ),
    );
  }
}

class SubtaskTile extends StatefulWidget {
  final Subtask subtask;
  final Task task;
  final Function(String) onCommentAdded;

  const SubtaskTile({
    Key? key,
    required this.subtask,
    required this.task,
    required this.onCommentAdded,
  }) : super(key: key);

  @override
  _SubtaskTileState createState() => _SubtaskTileState();
}

class _SubtaskTileState extends State<SubtaskTile> {
  bool _showComments = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.subtask.title),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(_showComments ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                  onPressed: () {
                    setState(() {
                      _showComments = !_showComments;
                    });
                  },
                ),
                Checkbox(
                  value: widget.subtask.isCompleted,
                  onChanged: (bool? value) {
                    setState(() {
                      widget.subtask.isCompleted = value ?? false;
                    });
                    context.read<TaskModel>().checkIfAllSubtasksDone(widget.task);
                    context.read<TaskModel>().checkIfAllTasksDone(widget.task.projectId);
                  },
                ),
              ],
            ),
          ),
          if (_showComments)
            Column(
              children: [
                if (widget.subtask.comments.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.subtask.comments.map((comment) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          '${comment.text} - ${comment.developerId}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }).toList(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Add a comment',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          if (_commentController.text.isNotEmpty) {
                            widget.onCommentAdded(_commentController.text);
                            _commentController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
