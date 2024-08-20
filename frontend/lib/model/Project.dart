import 'package:frontend/model/Task.dart';
import 'package:frontend/model/User.dart';

class Project {
  String projectId;
  String title;
  String description;
  List<Task> tasks;
  final List<User> developers;

  Project(this.projectId,this.title, this.description, this.tasks ,this.developers);
}
