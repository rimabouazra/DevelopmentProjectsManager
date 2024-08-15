import 'package:flutter/material.dart';
import 'package:frontend/model/Task.dart';

class TaskModel extends ChangeNotifier {
  final List<Task> tasks = [
    Task('task1',false,'task to do',DateTime.now().add(Duration(days: 1))),
    Task('task2',false,'task to do',DateTime.now().subtract(Duration(days: 1))),
    Task('task3',false,'task to do',DateTime.now().add(Duration(days: 7))),
    Task('task4',false,'task to do',DateTime.now().add(Duration(days: 13))),
  ];
  List<Task> get items => tasks;
 
 void markAsDone(int index){
  tasks[index].status=true;
  notifyListeners();
 }


}