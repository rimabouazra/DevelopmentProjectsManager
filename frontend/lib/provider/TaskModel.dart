import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/config/app_config.dart';
import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/Subtask.dart';
import 'package:frontend/model/Task.dart';
import 'package:frontend/library/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class TaskModel extends ChangeNotifier {
  final Map<String, List<Task>> tasks = {};
  Map<String, List<Task>> get items => tasks;
  final Map<String, List<Task>> tasksByProject = {};

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('x-access-token');
  }

  List<Task> getTasksByProject(String projectId) {
    return tasksByProject[projectId] ?? [];
  }

  int countTasksByDay(DateTime datetime) {
    String key = guessTodoKeyFromDate(datetime);
    if (tasks.containsKey(key)) {
      return tasks[key]!
          .where((task) =>
              task.deadline.day == datetime.day &&
              task.deadline.month == datetime.month &&
              task.deadline.year == datetime.year)
          .length;
    }
    return 0;
  }

  void add(Task task) {
    String key = guessTodoKeyFromDate(task.deadline);
    if (tasks.containsKey(key)) {
      tasks[key]!.add(task);
      notifyListeners();
    }
  }

  void markAsDone(String projectId, int taskIndex) {
    final task = tasksByProject[projectId]?[taskIndex];
    if (task != null) {
      task.status = !task.status;
      updateTask(task);
      checkIfAllTasksDone(projectId);
      notifyListeners();
    }
  }

  String guessTodoKeyFromDate(DateTime deadline) {
    if (deadline.isPast && !deadline.isToday) return globals.Late;
    if (deadline.isToday) return globals.today;
    if (deadline.isTomorrow) return globals.tomorrow;
    if (deadline.getWeek == DateTime.now().getWeek &&
        deadline.year == DateTime.now().year) return globals.thisWeek;
    if (deadline.getWeek == DateTime.now().getWeek + 1 &&
        deadline.year == DateTime.now().year) return globals.nextWeek;
    if (deadline.isThisMonth) return globals.thisMonth;
    return globals.later;
  }

  void addTaskToProject(String projectId, Task task) {
    if (projectId.isEmpty) {
      print("Error: projectId is empty, cannot add task to project.");
      return;
    }

    if (!tasksByProject.containsKey(projectId)) {
      tasksByProject[projectId] = [];
    }
    print('Adding task to project: ${task.title}, ID: ${task.id}'); // Debugging
    tasksByProject[projectId]!.add(task);
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final projectId = updatedTask.projectId;

    if (tasksByProject.containsKey(projectId)) {
      final taskIndex = tasksByProject[projectId]!
          .indexWhere((task) => task.id == updatedTask.id);

      if (taskIndex != -1) {
        tasksByProject[projectId]![taskIndex] = updatedTask;
        notifyListeners();
      }
    }
  }

  Future<void> fetchTasksForProject(String projectId) async {
    if (projectId.isEmpty) return;
    if (tasksByProject.containsKey(projectId)) return;

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/projects/$projectId/tasks'),
        headers: {'x-access-token': token},
      ).timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> tasksJson = json.decode(response.body);
        tasksByProject[projectId] =
            tasksJson.map((j) => Task.fromJson(j)).toList();
        notifyListeners();
      } else {
        throw Exception('Erreur lors du chargement des tâches');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<void> addTask(Task task) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    }

    final response = await http
        .post(
          Uri.parse('${AppConfig.baseUrl}/projects/${task.projectId}/tasks'),
          headers: {
            'Content-Type': 'application/json',
            'x-access-token': token,
          },
          body: json.encode({
            'title': task.title,
            'description': task.description,
            'dueDate': task.deadline.toIso8601String(),
            'developerNames': task.developerNames,
          }),
        )
        .timeout(AppConfig.requestTimeout);

    if (response.statusCode == 201) {
      final newTask = Task.fromJson(json.decode(response.body));
      // Forcer le rechargement depuis l'API
      tasksByProject.remove(newTask.projectId);
      await fetchTasksForProject(newTask.projectId);
      notifyListeners();
    } else {
      throw Exception('Erreur lors de la création de la tâche');
    }
  }

  Future<void> fetchTasksForAllProjects(List<String> projectIds) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    }

    for (final projectId in projectIds) {
      if (tasksByProject.containsKey(projectId)) continue;

      try {
        final response = await http.get(
          Uri.parse('${AppConfig.baseUrl}/projects/$projectId/tasks'),
          headers: {'x-access-token': token},
        ).timeout(AppConfig.requestTimeout);

        if (response.statusCode == 200) {
          final List<dynamic> tasksJson = json.decode(response.body);
          tasksByProject[projectId] =
              tasksJson.map((j) => Task.fromJson(j)).toList();
          notifyListeners();
        }
      } catch (e) {
        print('Erreur chargement tâches projet $projectId: $e');
      }
    }
  }

  void markSubtaskAsDone(Task task, Subtask subtask) {
    final taskIndex = tasksByProject[task.projectId]?.indexOf(task);
    final subtaskIndex = task.subtasks.indexOf(subtask);

    if (taskIndex != null && taskIndex != -1 && subtaskIndex != -1) {
      task.subtasks[subtaskIndex].isCompleted = !subtask.isCompleted;
      updateTask(task);
      notifyListeners();
    }
  }

  void addCommentToSubtask(Task task, Subtask subtask, String commentText) {
    final taskIndex = tasksByProject[task.projectId]?.indexOf(task);
    final subtaskIndex = task.subtasks.indexOf(subtask);
    if (taskIndex != null && taskIndex != -1 && subtaskIndex != -1) {
      subtask.addComment('currentDeveloperId', commentText);
      updateTask(task);
      notifyListeners();
    }
  }

  void checkIfAllSubtasksDone(Task task) {
    if (task.subtasks.every((subtask) => subtask.isCompleted)) {
      task.status = true;
      updateTask(task);
      notifyListeners();
    }
  }

  void checkIfAllTasksDone(String projectId) {
    if (tasksByProject[projectId]?.every((task) => task.status == true) ??
        false) {
      print(
          'All tasks in project $projectId are done. Mark the project as complete.');
    }
  }

  void removeTasksForProject(String projectId) {
    if (tasksByProject.containsKey(projectId)) {
      tasksByProject.remove(projectId);
      notifyListeners();
    }
  }
}
