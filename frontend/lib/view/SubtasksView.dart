import 'package:flutter/material.dart';
import 'package:frontend/model/Subtask.dart';
import 'package:frontend/model/Task.dart';


class SubtasksView extends StatefulWidget {
  final Task task;

  const SubtasksView({Key? key, required this.task}) : super(key: key);

  @override
  _SubtasksViewState createState() => _SubtasksViewState();
}

class _SubtasksViewState extends State<SubtasksView> {
  final TextEditingController _commentController = TextEditingController();
  String _selectedSubtaskId = '';

  void _addComment(Subtask subtask) {
    final developerId = "developerId";
    final text = _commentController.text;

    if (text.isNotEmpty) {
      setState(() {
        subtask.addComment(developerId, text);
      });
      _commentController.clear();
    }
  }

  void _checkIfAllSubtasksCompleted() {
    if (widget.task.subtasks.every((subtask) => subtask.isCompleted)) {
      setState(() {
        widget.task.status = true;
      });
      // Optionally, notify listeners or save this status in the backend.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: widget.task.subtasks.length,
          itemBuilder: (context, index) {
            final subtask = widget.task.subtasks[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(subtask.title, style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  _selectedSubtaskId = subtask.id;
                                });
                              },
                            ),
                            Checkbox(
                              value: subtask.isCompleted,
                              onChanged: (bool? value) {
                                setState(() {
                                  subtask.isCompleted = value ?? false;
                                  _checkIfAllSubtasksCompleted();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_selectedSubtaskId == subtask.id)
                      Column(
                        children: [
                          TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              labelText: 'Add a comment',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () => _addComment(subtask),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (subtask.comments.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Comments:', style: TextStyle(fontWeight: FontWeight.bold)),
                          for (var comment in subtask.comments)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                '${comment.text} - ${comment.developerId}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
