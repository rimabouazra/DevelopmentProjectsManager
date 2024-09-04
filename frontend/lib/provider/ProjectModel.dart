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

  Future<void> addProject(Project project, User user)async {
    if (user.canCreateProject()) {
      try {
        print("Creating project with token: ${user.token}");
        print("Request body: ${json.encode(project.toJson())}");

        final response = await http.post(
          Uri.parse('http://localhost:3000/projects'),
          headers: {
            'Content-Type': 'application/json',
            'x-access-token': user.token?? '',
          },
          body: json.encode(project.toJson()),
        );
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
        if (response.statusCode == 201) {
          projects.add(Project.fromJson(json.decode(response.body)));
          notifyListeners();
        } else {
          throw Exception('Failed to create project');
        }
      } catch (e) {
        throw Exception('Failed to create project: $e');
      }
    } else {
      print("User does not have permission to create projects.");
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
      throw Exception('Failed to fetch projects: $error');
    }
  }

}
