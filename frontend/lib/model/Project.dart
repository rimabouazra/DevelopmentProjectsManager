import 'package:frontend/model/Task.dart';

class Project {
  String title;
  String description;
  List<Task> tasks;

  Project(this.title, this.description, this.tasks);
}
