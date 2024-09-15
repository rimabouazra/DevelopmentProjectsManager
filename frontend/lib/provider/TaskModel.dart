import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/Subtask.dart';
import 'package:frontend/model/Task.dart';
import 'package:frontend/library/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class TaskModel extends ChangeNotifier {
  final Map<String, List<Task>> tasks = {
    globals.Late: [
      Task("1", "Task 1", "1", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)), [
        Subtask(id: "1", title: "Subtask 1", isCompleted: false),
        Subtask(id: "2", title: "Subtask 2", isCompleted: false),
      ], [
        "Rima"
      ])
    ],
    globals.today: [
      Task("2", "Today Task 2", "2", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)), [
        Subtask(id: "3", title: "Subtask 1", isCompleted: false),
        Subtask(id: "4", title: "Subtask 2", isCompleted: false),
      ], []),
      Task("1", "Today Task 2 ", "2", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)), [], [])
    ],
    globals.tomorrow: [
      Task("2", "Tomorrow Task 1", "1", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)), [], [])
    ],
    globals.thisWeek: [
      Task("2", " thisWeek Task 2", "2", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)), [], [])
    ],
    globals.nextWeek: [
      Task("1", "nextWeek Task 1", "1", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)), [], [])
    ],
    globals.thisMonth: [
      Task("1", "Task 2", "2", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)), [], ["Rima"])
    ],
    globals.later: [
      Task("1", "Task 1", "1", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)), [], ["Rima", "Rima"])
    ],
  };
  Map<String, List<Task>> get items => tasks;

  final Map<String, List<Task>> tasksByProject = {};

  List<Task> getTasksByProject(String projectId) {
    /*return tasks.values
        .expand((taskList) => taskList)
        .where((task) => task.projectId == projectId)
        .toList();*/

    if (tasksByProject.containsKey(projectId)) {
      return tasksByProject[projectId]!;
    }
    return [];
  }

  int countTasksByDay(DateTime _datetime) {
    String _key = guessTodoKeyFromDate(_datetime);
    if (tasks.containsKey(_key)) {
      return tasks[_key]!
          .where((task) =>
              task.deadline.day == _datetime.day &&
              task.deadline.month == _datetime.month &&
              task.deadline.year == _datetime.year)
          .length;
    }
    return 0;
  }

  void add(Task _task) {
    String _key = guessTodoKeyFromDate(_task.deadline);
    if (tasks.containsKey(_key)) {
      tasks[_key]!.add(_task);
      notifyListeners();
    }
  }

  void markAsDone(String projectId, int taskIndex) {
    final task = tasksByProject[projectId]?[taskIndex];
    if (task != null) {
      task.status = !task.status;
      updateTask(task);
      notifyListeners();
    }
  }

  String guessTodoKeyFromDate(DateTime deadline) {
    if (deadline.isPast && !deadline.isToday) {
      return globals.Late;
    } else if (deadline.isToday) {
      return globals.today;
    } else if (deadline.isTomorrow) {
      return globals.tomorrow;
    } else if (deadline.getWeek == DateTime.now().getWeek &&
        deadline.year == DateTime.now().year) {
      return globals.thisWeek;
    } else if (deadline.getWeek == DateTime.now().getWeek + 1 &&
        deadline.year == DateTime.now().year) {
      return globals.nextWeek;
    } else if (deadline.isThisMonth) {
      return globals.thisMonth;
    } else {
      return globals.later;
    }
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
    if (projectId.isEmpty) {
      print("Error: projectId is empty, cannot fetch tasks.");
      return;
    }
    if (tasksByProject.containsKey(projectId) &&
        tasksByProject[projectId]!.isNotEmpty) {
      print("Tasks already fetched for project: $projectId");
      return;
    }
    print("Fetching tasks for project ID: $projectId");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-access-token');
    print("Token fetched: $token"); // Debugging

    if (token == null || token.isEmpty) {
      print("Error: No token available for the user.");
      throw Exception('Failed to fetch tasks: No token provided');
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/projects/$projectId/tasks'),
        headers: {
          'x-access-token': token,
        },
      );

      if (response.statusCode == 200) {
        print('Response body: ${response.body}'); // Debugging
        final List<dynamic> tasksJson = json.decode(response.body);
        List<Task> tasks =
            tasksJson.map((json) => Task.fromJson(json)).toList();

        // Add the fetched tasks to the specific project
        if (!tasksByProject.containsKey(projectId)) {
          tasksByProject[projectId] = [];
        }
        tasksByProject[projectId] = tasks;
        notifyListeners();
      } else {
        print('Failed to fetch tasks: ${response.statusCode}'); // Debugging
        throw Exception('Failed to fetch tasks');
      }
    } catch (e) {
      print("Failed to fetch tasks: $e");
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  Future<void> addTask(Task task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-access-token');

    if (token == null || token.isEmpty) {
      print("Error: No token available for the user.");
      throw Exception('Failed to create task: No token provided');
    }

    print("Token fetched: $token"); // Debugging

    try {
      print(
          "Sending request to create task for project ID: ${task.projectId}"); // Debugging
      final response = await http.post(
        Uri.parse('http://localhost:3000/projects/${task.projectId}/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': token,
        },
        body: json.encode({
          "title": task.title,
          "description": task.description,
          "dueDate": task.deadline.toIso8601String(),
        }),
      );

      print('Response status: ${response.statusCode}'); // Debugging
      print('Response body: ${response.body}'); // Debugging

      if (response.statusCode == 201) {
        print("Task created successfully: ${response.body}");
        Task newTask = Task.fromJson(json.decode(response.body));
        await fetchTasksForProject(newTask.projectId);
        addTaskToProject(newTask.projectId, newTask);
        //await fetchTasksForProject(newTask.projectId);

        notifyListeners();
      } else {
        throw Exception('Failed to create task');
      }
    } catch (e) {
      print("Failed to create task: $e"); // Debugging
      throw Exception('Failed to create task: $e');
    }
  }

  Future<void> fetchTasksForAllProjects(List<String> projectIds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-access-token');

    if (token == null || token.isEmpty) {
      print("Error: No token available for the user.");
      throw Exception('Failed to fetch tasks: No token provided');
    }

    for (String projectId in projectIds) {
      print("Fetching tasks for project ID: $projectId");

      try {
        final response = await http.get(
          Uri.parse('http://localhost:3000/projects/$projectId/tasks'),
          headers: {
            'x-access-token': token,
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> tasksJson = json.decode(response.body);
          List<Task> tasks =
              tasksJson.map((json) => Task.fromJson(json)).toList();

          // Add the fetched tasks to the specific project
          if (!tasksByProject.containsKey(projectId)) {
            tasksByProject[projectId] = [];
          }
          tasksByProject[projectId] = tasks;
          notifyListeners();
        } else {
          print(
              'Failed to fetch tasks for project $projectId: ${response.statusCode}');
        }
      } catch (e) {
        print("Failed to fetch tasks for project $projectId: $e");
      }
    }
  }

  void markSubtaskAsDone(Task task, Subtask subtask) {
    final taskIndex = tasksByProject[task.projectId]?.indexOf(task);
    final subtaskIndex = task.subtasks.indexOf(subtask);

    if (taskIndex != -1 && subtaskIndex != -1) {
      task.subtasks[subtaskIndex].isCompleted = !subtask.isCompleted;
      updateTask(task);
      notifyListeners();
    }
  }

  void addCommentToSubtask(Task task, Subtask subtask, String commentText) {
  final taskIndex = tasksByProject[task.projectId]?.indexOf(task);
  final subtaskIndex = task.subtasks.indexOf(subtask);

  if (taskIndex != -1 && subtaskIndex != -1) {
    final developerId = 'currentDeveloperId'; // Replace with actual developer ID logic
    subtask.addComment(developerId, commentText);
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
  if (tasksByProject[projectId]?.every((task) => task.status == true) ?? false) {
    print('All tasks in project $projectId are done. Mark the project as complete.');
    // If you store the project status, you can add logic to update it here.
  }
}
}