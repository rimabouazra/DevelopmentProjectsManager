import 'package:flutter/material.dart';
import 'package:frontend/view/ProjectTasksView.dart';
import 'package:frontend/widget/ListTaskWidget.dart';
import 'package:provider/provider.dart';
import '../provider/ProjectModel.dart';

class ListProjectsWidget extends StatelessWidget {
  const ListProjectsWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectModel>().allProjects;

    return Scaffold(
      body: ListView.builder(
        itemCount: projects.length,
        physics: ScrollPhysics(),
        itemBuilder: (context, index) {
          final project = projects[index];
          return Card(
            child: ListTile(
              title: Text(project.title),
              subtitle: Text(project.description),
              trailing: ElevatedButton(
                child: Text("View Tasks"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: Text("${project.title} Tasks")),
                        body: ProjectTasksView(
                        projectId: project.projectId,
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
    );
  }
}
