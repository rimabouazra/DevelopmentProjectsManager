import 'package:frontend/model/Task.dart';

class Project {
  String projectId;
  String title;
  String description;
  List<Task> tasks;

  Project(this.projectId,this.title, this.description, this.tasks);
}
