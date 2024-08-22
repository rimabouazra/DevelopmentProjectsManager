import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/Subtask.dart';
import 'package:frontend/model/Task.dart';
import 'package:frontend/library/globals.dart' as globals;

class TaskModel extends ChangeNotifier {
  final Map<String, List<Task>> tasks = {
    globals.Late: [
      Task("1", "Task 1", "1", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)),[Subtask(id: "1", title: "Subtask 1", isCompleted: false),
          Subtask(id: "2", title: "Subtask 2", isCompleted: false),],["Rima"])
    ],
    globals.today: [
      Task("2", "Today Task 2", "2", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)),[Subtask(id: "3", title: "Subtask 1", isCompleted: false),
          Subtask(id: "4", title: "Subtask 2", isCompleted: false),],[]),
      Task("1", "Today Task 2 ", "2", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)),[],[])
    ],
    globals.tomorrow: [
      Task("2", "Tomorrow Task 1", "1", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)),[],[])
    ],
    globals.thisWeek: [
      Task("2", " thisWeek Task 2", "2", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)),[],[])
    ],
    globals.nextWeek: [
      Task("1", "nextWeek Task 1", "1", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)),[],[])
    ],
    globals.thisMonth: [
      Task("1", "Task 2", "2", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)),[],["Rima"])
    ],
    globals.later: [
      Task("1", "Task 1", "1", false, "Task's Descriptoion",
          DateTime.now().add(Duration(days: 1)),[],["Rima","Rima"])
    ],
  };
  Map<String, List<Task>> get items => tasks;

  final Map<String, List<Task>> tasksByProject = {};

  List<Task> getTasksByProject(String projectId) {
    return tasks.values
        .expand((taskList) => taskList)
        .where((task) => task.projectId == projectId)
        .toList();
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

  void markAsDone(String key, int index) {
    tasks[key]![index].status = true;
    notifyListeners();
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
    if (!tasksByProject.containsKey(projectId)) {
      tasksByProject[projectId] = [];
    }
    tasksByProject[projectId]!.add(task);
    notifyListeners();
  }
}
