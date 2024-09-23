import 'package:frontend/model/Subtask.dart';

class Task {
  String? id;
  String title;
  String projectId;
  bool isToDo = true;
  bool isInProgress = false; 
  bool status=false;
  String description;
  DateTime deadline;
  List<Subtask> subtasks;
  List<String> developerNames;

  Task(
    this.id,
    this.title,
    this.projectId,
    this.status,
    this.description,
    this.deadline,
    this.subtasks,
    this.developerNames,
    );

  void addSubtask(Subtask subtask) {
    subtasks.add(subtask);
  }

  void markAsDoneIfAllSubtasksCompleted() {
    if (subtasks.every((subtask) => subtask.isCompleted)) {
      status = true;
    }
  }

  void markAsInProgress() {
    isToDo = false;
    isInProgress = true;
  }

  void markAsCompleted() {
    isInProgress = false;
    status = true;
  }

   factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      json['taskId']?? '',
      json['title']?? '',
      json['projectId']?? '',
      json['completed']?? false,
      json['description']?? '',
      DateTime.parse(json['dueDate']),
      (json['subtasks'] as List)
          .map((subtask) => Subtask.fromJson(subtask))
          .toList(),
      List<String>.from(json['developerNames']?? []),
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'taskId': id,
      'title': title,
      'projectId': projectId,
      'completed': status,
      'description': description,
      'dueDate': deadline.toIso8601String(),
      'subtasks': subtasks.map((subtask) => subtask.toJson()).toList(),
      'developerNames': developerNames,
    };
  }
}
