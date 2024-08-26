import 'package:flutter/material.dart';
import 'package:frontend/widget/ListProjectWidget.dart';
import 'package:frontend/widget/ListTaskWidget.dart';

class ListTasksView extends StatefulWidget {
  final String? projectId;  // Accept projectId as an optional parameter

  const ListTasksView({Key? key, this.projectId}) : super(key: key);

  @override
  _ListTasksViewState createState() => _ListTasksViewState();
}

class _ListTasksViewState extends State<ListTasksView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("SoftwareDevelopmentProjectsManager"),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: const TabBar(
                isScrollable: true,
                labelColor: Colors.black,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: "Projects"),
                  Tab(text: "Tasks"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            ListProjectsWidget(),
            ListTasksWidget(
              projectId: widget.projectId,  // Pass the projectId to ListTasksWidget
            ),
          ],
        ),
      ),
    );
  }
}
