import 'package:flutter/material.dart';
import 'package:frontend/model/auth_helper.dart';
import 'package:frontend/widget/ListProjectWidget.dart';
import 'package:frontend/widget/ListTaskWidget.dart';

class ListTasksView extends StatefulWidget {
  final String? projectId;  // Accept projectId as an optional parameter

  const ListTasksView({Key? key, this.projectId}) : super(key: key);

  @override
  _ListTasksViewState createState() => _ListTasksViewState();
}

class _ListTasksViewState extends State<ListTasksView> {
   void signOutUser(BuildContext context) {
    AuthHelper().signOut(context);
  }
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
              projectId: widget.projectId,
            ),
          ],
        ),
        bottomNavigationBar: Padding(
  padding: const EdgeInsets.all(8.0),
  child: ElevatedButton(
    onPressed: () => signOutUser(context),
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.blue),
      textStyle: WidgetStateProperty.all(
        const TextStyle(color: Colors.white),
      ),
      minimumSize: WidgetStateProperty.all(
        Size(MediaQuery.of(context).size.width / 2.5, 50),
      ),
    ),
    child: const Text(
      "Sign Out",
      style: TextStyle(color: Colors.white, fontSize: 16),
    ),
  ),
),

      ),
    );
  }
}
