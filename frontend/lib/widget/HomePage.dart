import 'package:flutter/material.dart';
import 'package:frontend/model/User.dart';

class HomePage extends StatelessWidget {
  final User user;

  HomePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.nomUtilisateur}'),
            SizedBox(height: 20),
            if (user.canCreateProject())
              ElevatedButton(
                onPressed: () {
                  // Handle project creation
                },
                child: Text('Create Project'),
              ),
            if (user.canManageUsers())
              ElevatedButton(
                onPressed: () {
                  // Handle user management
                },
                child: Text('Manage Users'),
              ),
            if (user.canModifyProject())
              ElevatedButton(
                onPressed: () {
                  // Handle project modification
                },
                child: Text('Modify Project'),
              ),
          ],
        ),
      ),
    );
  }
}
