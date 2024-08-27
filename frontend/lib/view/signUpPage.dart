import 'package:flutter/material.dart';
import 'package:frontend/model/User.dart';
import 'package:frontend/model/auth_helper.dart';
import 'package:frontend/view/LoginPage.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final AuthHelper authHelper = AuthHelper();
  Role selectedRole = Role.Developer; // Default role


  void signupUser() {
    authHelper.signUpUser(
      context: context,
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
      role: selectedRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Signup",
            style: TextStyle(fontSize: 30),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
             child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
             child: TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text('Select Role'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.developer_mode),
                  color: selectedRole == Role.Developer ? Colors.blue : Colors.grey,
                  onPressed: () {
                    setState(() {
                      selectedRole = Role.Developer;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.manage_accounts),
                  color: selectedRole == Role.Manager ? Colors.blue : Colors.grey,
                  onPressed: () {
                    setState(() {
                      selectedRole = Role.Manager;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  color: selectedRole == Role.Administrator ? Colors.blue : Colors.grey,
                  onPressed: () {
                    setState(() {
                      selectedRole = Role.Administrator;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ElevatedButton(
            onPressed: signupUser,
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
              "Sign up",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            child: const Text('Login User?'),
          ),
        ],
      ),
    );
  }
}