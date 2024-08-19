import 'package:flutter/material.dart';
import 'package:frontend/model/Project.dart';
import 'package:frontend/model/Task.dart';

class ProjectModel extends ChangeNotifier {
  List<Project> projects = [
    Project("1","Project 1", "Description for Project 1", [
      Task("A","Task 1","1", false, "Description Task 1", DateTime.now().add(Duration(days: 1))),
      Task("B","Task 2","1", false, "Description Task 2", DateTime.now().add(Duration(days: 2))),
    ]),
    Project("2","Project 2", "Description for Project 2", [
      Task("C","Task A","2", false, "Description Task A", DateTime.now().add(Duration(days: 3))),
      Task("D","Task B","2", false, "Description Task B", DateTime.now().add(Duration(days: 4))),
    ]),
  ];

  List<Project> get allProjects => projects;

  List<Task> getTasksForProject(String projectId) {
    return projects.firstWhere((project) => project.projectId == projectId).tasks;
  }
}
