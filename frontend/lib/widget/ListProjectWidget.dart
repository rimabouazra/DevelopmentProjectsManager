import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/model/Project.dart';
import 'package:frontend/model/User.dart';
import 'package:frontend/model/auth_helper.dart';
import 'package:frontend/provider/DeveloperModel.dart';
import 'package:frontend/provider/ProjectModel.dart';
import 'package:frontend/provider/TaskModel.dart';
import 'package:frontend/view/ProjectTasksView.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ListProjectsWidget extends StatefulWidget {
  @override
  ListProjectsWidgetState createState() => ListProjectsWidgetState();
}

class ListProjectsWidgetState extends State<ListProjectsWidget> {
  List<dynamic> _projects = [];
  bool isLoading = true;
  String errorMessage = '';
  bool isProcessing = false;
  String userRole = '';

  @override
  void initState() {
    super.initState();
    //fetchProjects();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserRole();
      Provider.of<ProjectModel>(context, listen: false).fetchProjects();
    });
  }

  Future<void> fetchProjects() async {
    final tokens = await AuthHelper.getTokens();
    final accessToken = tokens['accessToken'];

    if (accessToken == null || accessToken.isEmpty) {
      setState(() {
        errorMessage = 'No access token found';
        isLoading = false;
      });
      return;
    }
    print("Fetching projects with access token: $accessToken");

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/projects'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-access-token': accessToken,
        },
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          final List<dynamic> projectList = json.decode(response.body);
          if (projectList.isEmpty) {
            errorMessage = "No projects found.";
          } else {
            _projects = projectList.map((json) => Project.fromJson(json)).toList();
          }
          isLoading = false;
        });
      } else {
        isLoading = false;
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  Future<void> confirmDeleteProject(String projectId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Project"),
          content: Text("Are you sure you want to delete this project?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await Provider.of<ProjectModel>(context, listen: false)
                      .deleteProject(projectId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Project deleted successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete project: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
   Future<void> _fetchUserRole() async {
    final developerModel = Provider.of<DeveloperModel>(context, listen: false);
    final user = developerModel.user;  
    setState(() {
      userRole = user.role.toString(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectModel = Provider.of<ProjectModel>(context, listen: false);
    final taskModel = Provider.of<TaskModel>(context, listen: false);

    void deleteProject(String projectId) async {
      try {
        await projectModel.deleteProject(projectId);
        taskModel.removeTasksForProject(projectId);
      } catch (e) {
        print('Failed to delete project: $e');
      }
    }
    return Scaffold(
      body: Consumer<ProjectModel>(
        builder: (context, projectModel, child) {
          if (projectModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (projectModel.errorMessage.isNotEmpty) {
            return Center(child: Text(projectModel.errorMessage));
          }

          return ListView.builder(
            itemCount: projectModel.projects.length,
            itemBuilder: (context, index) {
              final project = projectModel.projects[index];
              return Card(
                child: ListTile(
                  title: Text(project.title),
                  subtitle: Text(project.description),
                  trailing:  userRole == 'Role.Manager'
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            'EditProject', 
                            arguments: project.projectId, 
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () =>
                            confirmDeleteProject(project.projectId),
                      ),
                      ElevatedButton(
                        child: Text("View Tasks"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                    title: Text("${project.title} Tasks")),
                                body: ProjectTasksView(
                                  projectId: project.projectId,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ) :null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:  userRole == 'Role.Manager'
          ?FloatingActionButton(
        heroTag: UniqueKey(),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "CreateProject");
        },
      ) :null,
    );
  }
}
