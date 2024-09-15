import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/model/Project.dart';
import 'package:frontend/model/Task.dart';
import 'package:frontend/model/User.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProjectModel extends ChangeNotifier {
  List<Project> projects = [];

  bool isLoading = false;
  String errorMessage = ''; 

  List<Project> get allProjects => projects;

  List<Task> getTasksForProject(String projectId) {
    return projects
        .firstWhere((project) => project.projectId == projectId)
        .tasks;
  }

  Future<void> addProject(Project project, User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-access-token');

    if (token == null || token.isEmpty) {
      print("Error: No token available for the user.");
      throw Exception('Failed to create project: No token provided');
    }
    if (user.canCreateProject()) {
      try {
        print("Creating project with token: $token");
        print("Request body: ${json.encode(project.toJson())}");

        final response = await http.post(
          Uri.parse('http://localhost:3000/projects'),
          headers: {
            'Content-Type': 'application/json',
            'x-access-token': token,
          },
          body: json.encode(
              //project.toJson(),
              {
                "title": project.title,
                "description": project.description,
                "tasks": project.tasks.isNotEmpty ? project.tasks : [],
                "developers":
                    project.developers.map((dev) => dev.toJson()).toList(),
              }),
        );
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['tasks'] == null) {
            jsonResponse['tasks'] = []; 
          }
          
          projects.add(Project.fromJson(json.decode(response.body)));
          notifyListeners();
          await fetchProjects();
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

  void setProjects(List<Project> newProjects) {
    projects = newProjects;
    notifyListeners();
  }

  Future<void> fetchProjects() async {
     isLoading = true; 
    errorMessage = ''; 
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-access-token');

    if (token == null || token.isEmpty) {
      print("Error: No access token found.");
      return;
    }
    final url = 'http://localhost:3000/projects';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-access-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> projectList = json.decode(response.body);
        if (projectList.isEmpty) {
          errorMessage = "No projects found.";
          print("No projects found"); // Debugging
          return;
        }
        print('Raw project JSON: $projectList'); // Debugging

        projects = projectList.map((json) => Project.fromJson(json)).toList();
        print('Parsed projects: ${projects.length}');// Debugging
        notifyListeners();
      } else {
        errorMessage = 'Failed to load projects. Status: ${response.statusCode}';
        throw Exception('Failed to load projects');
      }
    } catch (error) {
      throw Exception('Failed to fetch projects: $error');
    } finally {
      isLoading = false;  // Stop loading
      notifyListeners();
    }
  }

  List<String> getProjectIds() {
  return projects.map((project) => project.projectId).toList();
}

Future<void> deleteProject(String projectId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('x-access-token');

  if (token == null || token.isEmpty) {
    print("Error: No access token found.");
    errorMessage = "No access token found.";
    notifyListeners();
    return;
  }

  final response = await http.delete(
    Uri.parse('http://localhost:3000/projects/$projectId'),
    headers: {
      'x-access-token': token,
    },
  );

  if (response.statusCode == 200) {
    projects.removeWhere((project) => project.projectId == projectId);
    notifyListeners();
  } else {
    throw Exception('Failed to delete project');
  }
}

Future<void> updateProject(Project project) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('x-access-token');

  if (token == null || token.isEmpty) {
    print("Error: No access token found.");
    return;
  }

  final response = await http.patch(
    Uri.parse('http://localhost:3000/projects/${project.projectId}'),
    headers: {
      'Content-Type': 'application/json',
      'x-access-token': token,
    },
    body: json.encode({
      'title': project.title,
      'description': project.description,
    }),
  );

  if (response.statusCode == 200) {
    final index = projects.indexWhere((p) => p.projectId == project.projectId);
    if (index != -1) {
      projects[index] = project;
      notifyListeners();
    }
  } else {
    throw Exception('Failed to update project');
  }
}


}
