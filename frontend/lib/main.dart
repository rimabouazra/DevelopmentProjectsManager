import 'package:flutter/material.dart';
import 'package:frontend/model/Task.dart';
import 'package:frontend/provider/DeveloperModel.dart';
import 'package:frontend/provider/ProjectModel.dart';
import 'package:frontend/provider/TaskModel.dart';
import 'package:frontend/view/AddTasksView.dart';
import 'package:frontend/view/ListTasksView.dart';
import 'package:frontend/view/SubtasksView.dart';
import 'package:frontend/view/createProjectView.dart';
import 'package:frontend/widget/ListProjectWidget.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskModel()),
        ChangeNotifierProvider(create: (_) => ProjectModel()),
        ChangeNotifierProvider(create: (_) => DeveloperModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SoftwareDevelopmentProjectsManager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        "ListTasks": (context) => ListTasksView(),
        "addTasks": (context) => AddTasksView(),
        "ListProjects": (context) => ListProjectsWidget(),
        "CreateProject": (context) => CreateProjectView(),
        'viewTaskDetails': (context) => SubtasksView(
              task: ModalRoute.of(context)!.settings.arguments as Task,
            ),
      },
      home: ListTasksView(),
    );
  }
}
