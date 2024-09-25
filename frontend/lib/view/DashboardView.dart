import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Map<String, int> projectStats = {
    'assigned': 0,
    'in_progress': 0,
    'completed': 0
  };

  @override
  void initState() {
    super.initState();
    fetchProjectStats();
  }

  Future<void> fetchProjectStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-access-token');
    print("Sending token: $token"); // Debugging line
    if (token == null || token.isEmpty) {
      print('Error: No token found');
    }
    final response =
        await http.get(Uri.parse('http://localhost:3000/dashboard/projects'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        for (var stat in data) {
          projectStats[stat['_id']] = stat['count'];
        }
      });
    } else {
      print('Failed to fetch project stats');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Project Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatCard('Assigned Projects', projectStats['assigned'] ?? 0,
                Colors.blue),
            _buildStatCard('In-Progress Projects',
                projectStats['in_progress'] ?? 0, Colors.orange),
            _buildStatCard('Completed Projects', projectStats['completed'] ?? 0,
                Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              '$count',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
