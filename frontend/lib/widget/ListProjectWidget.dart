import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/model/auth_helper.dart';
import 'package:frontend/provider/ProjectModel.dart';
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

  @override
  void initState() {
    super.initState();
    fetchProjects();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
          _projects = json.decode(response.body);
           isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to fetch projects. Status: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
    if (mounted) {
      setState(() {
        errorMessage = 'Failed to fetch projects. Error: $e';
        isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              :ListView.builder(
        itemCount: _projects.length,
        physics: ScrollPhysics(),
        itemBuilder: (context, index) {
          final project = _projects[index];
          return Card(
            child: ListTile(
              title: Text(project['title'] ?? 'Unnamed Project'),
              subtitle: Text(project['description'] ?? 'No Description'),
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
                          projectId: project['_id'], // Pass the projectId to the ProjectTasksView
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
