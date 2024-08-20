import 'package:frontend/model/Subtask.dart';

class Task {
  String? id;
  String title;
  String projectId; 
  bool status;
  String description;
  DateTime deadline;
  List<Subtask> subtasks;
  List<String> developerNames;

  Task(this.id,this.title,this.projectId,this.status,this.description,this.deadline,this.subtasks,this.developerNames);
}
