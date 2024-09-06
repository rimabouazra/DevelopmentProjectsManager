import 'package:frontend/model/Task.dart';
import 'package:frontend/model/User.dart';

class Project {
  String projectId;
  String title;
  String description;
  List<Task> tasks;
  final List<User> developers;

  Project(this.projectId, this.title, this.description, this.tasks,
      this.developers);

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      json['projectId'] ?? '',
      json['title'] ?? 'No Title',
      json['description'] ?? '',
      json['tasks'] != null? (json['tasks'] as List)
              .map((taskJson) => Task.fromJson(taskJson))
              .toList()
          : [],
      json['developers'] != null 
            ? (json['developers'] as List).map((devJson) => User.fromJson(devJson)).toList() 
            : [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'title': title,
      'description': description,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'developers': developers.map((developer) => developer.toJson()).toList(),
    };
  }
}
