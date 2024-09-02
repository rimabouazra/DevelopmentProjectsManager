import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/model/auth_helper.dart';
import 'package:frontend/view/ProjectTasksView.dart';
import 'package:http/http.dart' as http;

class ListProjectsWidget extends StatefulWidget {
  @override
  ListProjectsWidgetState createState() => ListProjectsWidgetState();
}

class ListProjectsWidgetState extends State<ListProjectsWidget> {
  List<dynamic> _projects = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    final tokens = await AuthHelper.getTokens();
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/projects'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-access-token': tokens['accessToken']!,
        },
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _projects = json.decode(response.body);
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to fetch projects. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
    if (mounted) {
      setState(() {
        errorMessage = 'Failed to fetch projects. Error: $e';
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _projects.length,
        physics: ScrollPhysics(),
        itemBuilder: (context, index) {
          final project = _projects[index];
          return Card(
            child: ListTile(
              title: Text(project['title']),
              subtitle: Text(project['description']),
              trailing: ElevatedButton(
                child: Text("View Tasks"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar:
                            AppBar(title: Text("${project['title']} Tasks")),
                        body: ProjectTasksView(
                          projectId: project[
                              'projectId'], // Pass the projectId to the ProjectTasksView
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: UniqueKey(),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "CreateProject");
        },
      ),
    );
  }
}
