import 'package:flutter/material.dart';
import 'package:frontend/widget/ListTaskWidget.dart';

class ListTasksView extends StatefulWidget {
  const ListTasksView({Key? key}) : super(key: key);

  @override
  _ListTasksViewState createState() => _ListTasksViewState();
}

class _ListTasksViewState extends State<ListTasksView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
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
                  Tab(text: "Subtasks"),
                ],
              ),
            ),
            ),
          ),
          body: const TabBarView(
            children: [
              ListTasksWidget(),
              ListTasksWidget(),
              ListTasksWidget(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () { 
              Navigator.pushNamed(context, "addTasks");
             },
          ),
        )
      );
  }
}
