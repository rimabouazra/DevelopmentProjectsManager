import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/model/User.dart';
import 'package:frontend/provider/DeveloperModel.dart';
import 'package:frontend/view/ListTasksView.dart';
import 'package:frontend/view/signUpPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthHelper {
  void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  void httpErrorHandle({
    required http.Response response,
    required BuildContext context,
    required VoidCallback onSuccess,
  }) {
    try {
      final Map<String, dynamic> responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      switch (response.statusCode) {
        case 200:
          onSuccess();
          break;
        case 400:
          showSnackBar(context, responseData['error'] ?? 'Bad Request');
          break;
        case 500:
          showSnackBar(context, responseData['error'] ?? 'Server Error');
          break;
        default:
          showSnackBar(context, response.body);
      }
    } catch (e) {
      showSnackBar(context, 'Unexpected error: ${e.toString()}');
    }
  }

  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required Role role,
  }) async {
    try {
      User user = User(
        idUtilisateur: '',
        nomUtilisateur: name,
        motDePasse: password,
        email: email,
        token: '',
        role: role,
      );
      //debugging
      print("Signup request body: ${user.toMap()}");

      http.Response res = await http.post(
        Uri.parse('http://localhost:3000/users'),
        body: jsonEncode(user.toMap()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          showSnackBar(
            context,
            'Account created! Login with the same credentials!',
          );
          SharedPreferences prefs = await SharedPreferences.getInstance();
          //var responseBody = jsonDecode(res.body);

          String? refreshToken = res.headers['x-refresh-token'];
          String? accessToken = res.headers['x-access-token'];

          await prefs.setString('x-refresh-token', refreshToken!);
          await prefs.setString('x-access-token', accessToken!);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void LogInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      print(
          "Attempting to log in with email: $email and password: $password"); // Debugging line
      var userProvider = Provider.of<DeveloperModel>(context, listen: false);
      final navigator = Navigator.of(context);
      http.Response res = await http.post(
        Uri.parse('http://localhost:3000/users/login'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print("Server response: ${res.statusCode} ${res.body}"); // Debugging line

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          //final responseData = jsonDecode(res.body);
          userProvider.setUser(res.body);

          print("Access Token: ${res.headers['x-access-token']}");
          print("Refresh Token: ${res.headers['x-refresh-token']}");
          //await prefs.setString('x-access-token', responseData['token']);
          await prefs.setString(
              'x-refresh-token', res.headers['x-refresh-token'] ?? '');
          await prefs.setString(
              'x-access-token', res.headers['x-access-token'] ?? '');

          navigator.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => ListTasksView(),
            ),
            (route) => false,
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('x-access-token', '');
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const SignupPage(),
      ),
      (route) => false,
    );
  }

  // Function to get stored tokens
  static Future<Map<String, String>> getTokens() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'accessToken': prefs.getString('accessToken') ?? '',
      'refreshToken': prefs.getString('refreshToken') ?? '',
    };
  }

  // Function to store tokens
  static Future<void> saveTokens(
      String accessToken, String refreshToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  // Function to clear tokens
  static Future<void> clearTokens() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }
}
