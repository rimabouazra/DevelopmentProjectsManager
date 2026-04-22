import 'package:frontend/model/Task.dart';
import 'package:frontend/model/User.dart';

class Project {
  String projectId;
  String title;
  String description;
  List<Task> tasks;
  List<User> developers;
  User? manager;
  String status;

  Project(
    this.projectId,
    this.title,
    this.description,
    this.tasks,
    this.developers,
    this.manager, {
    this.status = 'assigned', // valeur par défaut
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      json['_id'] ?? '',
      json['title'] ?? 'Sans titre',
      json['description'] ?? '',
      json['tasks'] != null
          ? (json['tasks'] as List)
              .map((taskJson) => Task.fromJson(taskJson))
              .toList()
          : [],
      json['developers'] != null
          ? (json['developers'] as List)
              .map((devJson) => User.fromJson(devJson))
              .toList()
          : [],
      json['manager'] != null ? User.fromJson(json['manager']) : null,
      status: json['status'] ?? 'assigned', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'developers': developers.map((dev) => dev.toJson()).toList(),
      'manager': manager != null ? manager!.toJson() : null,
    };
  }

  @override
  String toString() {
    return 'Project(projectId: $projectId, title: $title, status: $status)';
  }
}