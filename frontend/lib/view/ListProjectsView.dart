import 'package:flutter/material.dart';
import 'package:frontend/widget/ListTaskWidget.dart';
import 'package:provider/provider.dart';
import '../provider/ProjectModel.dart';

class ListProjectsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectModel>().allProjects;

    return Scaffold(
      appBar: AppBar(title: Text("Projects")),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Material(
            child: ListTile(
              title: Text(project.title),
              subtitle: Text(project.description),
              trailing: ElevatedButton(
                child: Text("View Tasks"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListTasksWidget(projectId: project.projectId),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
