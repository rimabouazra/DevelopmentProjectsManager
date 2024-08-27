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
  final AuthHelper authHelper = AuthHelper();


  void login() async {
  
    authHelper.LogInUser(
      context: context,
      email: emailController.text,
      password: passwordController.text,
    );
  }

  // Simulated authentication function
  /*User? authenticateUser(String email, String password) {
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
  }*/

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
