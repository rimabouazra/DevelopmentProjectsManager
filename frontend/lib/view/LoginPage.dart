import 'package:flutter/material.dart';
import 'package:frontend/model/User.dart';
import 'package:frontend/view/ListTasksView.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  void login(BuildContext context) {
    String email = emailController.text;
    String password = passwordController.text;

    // Simulate user authentication and role assignment based on email
    User? user = authenticateUser(email, password);
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ListTasksView()),
      );
    } else {
      setState(() {
        errorMessage = 'Invalid email or password';
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
            ElevatedButton(
              onPressed: () => login(context),
              child: Text('Login'),
            ),
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
