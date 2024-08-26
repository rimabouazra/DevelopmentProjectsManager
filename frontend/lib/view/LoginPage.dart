import 'dart:convert';
import 'package:frontend/model/auth_helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';


  void login() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/users/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // ignore: unused_local_variable
        final Map<String, dynamic> data = json.decode(response.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        await AuthHelper.saveTokens(
          response.headers['x-access-token']!,
          response.headers['x-refresh-token']!,
        );

        Navigator.pushReplacementNamed(context, 'ListProjects');
      } else {
        setState(() {
          errorMessage = 'Login failed. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Login failed. Error: $e';
      });
    }
  }

  // Simulated authentication function
  User? authenticateUser(String email, String password) {
    List<User> users = [
      User(
        idUtilisateur: '1',
        nomUtilisateur: 'John Doe',
        email: 'developer@example.com',
        motDePasse: 'password123',
        role: Role.Developer,
      ),
      User(
        idUtilisateur: '2',
        nomUtilisateur: 'Jane Smith',
        email: 'manager@example.com',
        motDePasse: 'password123',
        role: Role.Manager,
      ),
      User(
        idUtilisateur: '3',
        nomUtilisateur: 'Admin User',
        email: 'admin@example.com',
        motDePasse: 'password123',
        role: Role.Administrator,
      ),
    ];

    for (var user in users) {
      if (user.email == email && user.motDePasse == password) {
        return user;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text('Login')),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
