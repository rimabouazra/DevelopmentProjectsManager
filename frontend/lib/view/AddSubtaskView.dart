import 'package:flutter/material.dart';
import 'package:frontend/model/Task.dart';
import 'package:frontend/model/Subtask.dart';
import 'package:provider/provider.dart';
import 'package:frontend/provider/TaskModel.dart';

class AddSubtaskView extends StatefulWidget {
  final Task task;

  const AddSubtaskView({Key? key, required this.task}) : super(key: key);

  @override
  _AddSubtaskViewState createState() => _AddSubtaskViewState();
}

class _AddSubtaskViewState extends State<AddSubtaskView> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _addSubtask() {
    if (_formKey.currentState?.validate() ?? false) {
      final newSubtask = Subtask(
        id: UniqueKey().toString(),
        title: _titleController.text,
      );

      setState(() {
        widget.task.subtasks.add(newSubtask);
      });

      final taskModel = Provider.of<TaskModel>(context, listen: false);
      taskModel.updateTask(widget.task);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Subtask'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Add subtask for task: ${widget.task.title}'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addSubtask,
                child: Text('Add Subtask'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
