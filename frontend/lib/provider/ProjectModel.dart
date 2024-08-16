import 'package:flutter/material.dart';
import 'package:frontend/model/Project.dart';
import 'package:frontend/model/Task.dart';

class TaskModel extends ChangeNotifier {
  List<Project> projects = [
    Project("Project 1", "Description for Project 1", [
      Task("Task 1", false, "Description Task 1", DateTime.now().add(Duration(days: 1))),
      Task("Task 2", false, "Description Task 2", DateTime.now().add(Duration(days: 2))),
    ]),
    Project("Project 2", "Description for Project 2", [
      Task("Task A", false, "Description Task A", DateTime.now().add(Duration(days: 3))),
      Task("Task B", false, "Description Task B", DateTime.now().add(Duration(days: 4))),
    ]),
  ];

  List<Project> get allProjects => projects;

  List<Task> getTasksForProject(Project project) {
    return project.tasks;
  }
}
