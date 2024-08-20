import 'package:flutter/material.dart';
import 'package:frontend/model/Task.dart';

class SubtasksView extends StatelessWidget {
  final Task task;

  const SubtasksView({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 8),
            Text(
              'Deadline: ${task.deadline.toLocal().toString().split(' ')[0]}',
              style: TextStyle(
                fontSize: 16,
                color: _getDeadlineColor(task.deadline),
              ),
            ),
            SizedBox(height: 8),
            Text('Status: ${task.status ? "Completed" : "Pending"}', style: TextStyle(fontSize: 16,color: task.status ? Colors.green : Colors.red,fontWeight: FontWeight.bold,),),
            SizedBox(height: 16),
            Text('Subtasks:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: task.subtasks.length,
                itemBuilder: (context, index) {
                  final subtask = task.subtasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        subtask.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            'Comments: ${subtask.comments.map((c) => c.text).join(', ')}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Status: ${subtask.status ? "Completed" : "Pending"}',
                            style: TextStyle(
                              color: subtask.status ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      trailing: Checkbox(
                        value: subtask.status,
                        onChanged: (bool? value) {
                          // Handle subtask status change
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDeadlineColor(DateTime deadline) {
    final now = DateTime.now();
    if (deadline.isBefore(now)) {
      return Colors.red;
    } else if (deadline.year == now.year &&
        deadline.month == now.month &&
        deadline.day == now.day) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}

