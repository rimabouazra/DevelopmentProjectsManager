import 'package:flutter/material.dart';
import 'package:frontend/model/Task.dart';
import 'package:frontend/model/User.dart';
import 'package:frontend/provider/DeveloperModel.dart';
import 'package:frontend/provider/NotificationModel.dart';
import 'package:frontend/provider/ProjectModel.dart';
import 'package:frontend/provider/TaskModel.dart';
import 'package:frontend/view/AddSubtaskView.dart';
import 'package:frontend/view/AddTasksView.dart';
import 'package:frontend/view/EditProjectView.dart';
import 'package:frontend/view/ListTasksView.dart';
import 'package:frontend/view/SubtasksView.dart';
import 'package:frontend/view/createProjectView.dart';
import 'package:frontend/view/signUpPage.dart';
import 'package:frontend/widget/ListProjectWidget.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskModel()),
         ChangeNotifierProvider(create: (_) => NotificationModel()),
        ChangeNotifierProvider(create: (_) => ProjectModel()),
        ChangeNotifierProvider(create: (_) => DeveloperModel()),
        ChangeNotifierProvider(create: (_) => User(
          idUtilisateur: '', //a default value
            nomUtilisateur: '',
            email: '',
            role: Role.Developer,
        )),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
        "EditProject": (context) => EditProjectView(projectId: ModalRoute.of(context)!.settings.arguments as String),
        "addTasks": (context) => AddTasksView(),
        "ListProjects": (context) => ListProjectsWidget(),
        "CreateProject": (context) => CreateProjectView(),
        'viewTaskDetails': (context) => SubtasksView(
              task: ModalRoute.of(context)!.settings.arguments as Task,
            ),
        'addSubtask': (context) {
      final Task task = ModalRoute.of(context)!.settings.arguments as Task;
      return AddSubtaskView(task: task); // Define your AddSubtaskView here
    },
      },
      home: Builder(
        builder: (context) {
          final developerModel = Provider.of<DeveloperModel>(context, listen: true);
if (developerModel.user == null || developerModel.user!.token == null) {
            return const SignupPage();
          }

          // Safely access the token
          return developerModel.user!.token!.isEmpty
              ? const SignupPage()
              : ListProjectsWidget();        },
      ),
    );
  }
}
