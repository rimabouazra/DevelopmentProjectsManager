import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/model/Project.dart';
import 'package:frontend/model/Task.dart';
import 'package:frontend/model/User.dart';
import 'package:http/http.dart' as http;


class ProjectModel extends ChangeNotifier {
  List<Project> projects = [];

  List<Project> get allProjects => projects;

  List<Task> getTasksForProject(String projectId) {
    return projects.firstWhere((project) => project.projectId == projectId).tasks;
  }

  void addProject(Project project, User user) {
    if (user.canCreateProject()) {
      projects.add(project);
      notifyListeners();
    } else {
      throw Exception("User does not have permission to create projects.");
    }
  }

   void updateProject(Project project, User user) {
    if (user.canModifyProject()) {
      // Update logic here
      notifyListeners();
    } else {
      throw Exception("User does not have permission to modify projects.");
    }
  }

  void setProjects(List<Project> newProjects) {
  projects = newProjects;
  notifyListeners();
}
  Future<void> fetchProjects() async {
    final url = 'http://localhost:3000/projects'; 

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-access-token': 'x-access-token', 
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> projectList = json.decode(response.body);
        projects = projectList.map((json) => Project.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load projects');
      }
    } catch (error) {
      throw error;
    }
  }

}
