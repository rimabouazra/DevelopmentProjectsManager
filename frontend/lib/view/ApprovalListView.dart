import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ApprovalListView extends StatefulWidget {
  @override
  _ApprovalListViewState createState() => _ApprovalListViewState();
}

class _ApprovalListViewState extends State<ApprovalListView> {
  List<dynamic> pendingUsers = [];

  @override
  void initState() {
    super.initState();
    fetchPendingUsers();
  }

  Future<void> fetchPendingUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-access-token');
    print("Sending token: $token"); // Debugging line
    if (token == null || token.isEmpty) {
      print('Error: No token found');
    } else {
      final response = await http.get(
        Uri.parse('http://localhost:3000/users/pending-approval'),
        headers: {'x-access-token': token},
      );
      if (response.statusCode == 200) {
        setState(() {
          pendingUsers = json.decode(response.body);
        });
      } else {
        print('Failed to fetch pending users'); 
        print(
            'Error status code: ${response.statusCode}, Body: ${response.body}');
      }
    }
  }

  Future<void> approveUser(String userId) async {
    final response = await http
        .patch(Uri.parse('http://localhost:3000/users/approve/$userId'));
    if (response.statusCode == 200) {
      setState(() {
        pendingUsers.removeWhere((user) => user['_id'] == userId);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User approved')));
    } else {
      print('Failed to approve user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pending User Approvals')),
      body: ListView.builder(
        itemCount: pendingUsers.length,
        itemBuilder: (context, index) {
          final user = pendingUsers[index];
          return ListTile(
            title: Text(user['name']),
            subtitle: Text(user['email']),
            trailing: IconButton(
              icon: Icon(Icons.check),
              onPressed: () => approveUser(user['_id']),
            ),
          );
        },
      ),
    );
  }
}
