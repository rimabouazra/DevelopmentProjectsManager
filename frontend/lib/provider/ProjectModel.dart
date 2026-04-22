import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/model/Project.dart';
import 'package:frontend/model/Task.dart';
import 'package:frontend/model/User.dart';
import 'package:frontend/provider/TaskModel.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
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

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('x-access-token');
  }

  Future<void> addProject(
      Project project, User user, User? selectedManager) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    }
    if (!user.canCreateProject()) {
      throw Exception("Vous n'avez pas la permission de créer des projets.");
    }
    try {
      print("Creating project with token: $token");
      print("Request body: ${json.encode(project.toJson())}");

      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/projects'),
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
                  'developers': project.developers
                      .map((dev) => dev.idUtilisateur)
                      .where((id) => id.isNotEmpty)
                      .toList(),
                  "managerId": selectedManager?.idUtilisateur,
                }),
          )
          .timeout(AppConfig.requestTimeout);
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
  }

  void setProjects(List<Project> newProjects) {
    projects = newProjects;
    notifyListeners();
  }

  Future<void> fetchProjects() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        errorMessage = 'Session expirée. Veuillez vous reconnecter.';
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/projects'),
        headers: {'x-access-token': token},
      ).timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> projectList = json.decode(response.body);
        if (projectList.isEmpty) {
          errorMessage = 'Aucun projet trouvé.';
          projects = [];
        } else {
          projects = projectList.map((j) => Project.fromJson(j)).toList();
        }
        notifyListeners();
      } else if (response.statusCode == 401) {
        errorMessage = 'Session expirée. Veuillez vous reconnecter.';
      } else {
        errorMessage = 'Erreur lors du chargement des projets.';
      }
    } catch (e) {
      errorMessage = 'Impossible de contacter le serveur.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<String> getProjectIds() {
    return projects.map((project) => project.projectId).toList();
  }

  Future<void> deleteProject(String projectId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Session expirée.');
    }

    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/projects/$projectId'),
      headers: {'x-access-token': token},
    ).timeout(AppConfig.requestTimeout);

    if (response.statusCode == 200) {
      projects.removeWhere((p) => p.projectId == projectId);
      notifyListeners();
    } else {
      throw Exception('Erreur lors de la suppression du projet');
    }
  }

  Future<void> updateProject(Project project) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Session expirée.');
    }

    final response = await http
        .patch(
          Uri.parse('${AppConfig.baseUrl}/projects/${project.projectId}'),
          headers: {
            'Content-Type': 'application/json',
            'x-access-token': token,
          },
          body: json.encode({
            'title': project.title,
            'description': project.description,
            'developers':
                project.developers.map((d) => d.idUtilisateur).toList(),
          }),
        )
        .timeout(AppConfig.requestTimeout);

    if (response.statusCode == 200) {
      final index =
          projects.indexWhere((p) => p.projectId == project.projectId);
      if (index != -1) {
        projects[index] = project;
        notifyListeners();
      }
    } else {
      throw Exception('Erreur lors de la mise à jour du projet');
    }
  }
}
