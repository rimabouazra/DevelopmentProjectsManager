import 'package:flutter/material.dart';
import 'package:frontend/model/User.dart';

class HomePage extends StatelessWidget {
  final User user;

  HomePage({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.role != Role.Administrator) {
      return Scaffold(
        body: Center(child: Text('Access Denied: Administrator Role Required')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Administrator Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.group),
              label: Text('Pending User Approvals'),
              onPressed: () {
                Navigator.pushNamed(context, '/approvalList');
              },
            ),
            SizedBox(height: 20),

            ElevatedButton.icon(
              icon: Icon(Icons.add_box),
              label: Text('Request to Create Project'),
              onPressed: () {
                Navigator.pushNamed(context, '/createProjectView');
              },
            ),
            SizedBox(height: 20),

            ElevatedButton.icon(
              icon: Icon(Icons.dashboard),
              label: Text('Project Dashboard'),
              onPressed: () {
                Navigator.pushNamed(context, '/dashboardView');
              },
            ),
          ],
        ),
      ),
    );
  }
}
