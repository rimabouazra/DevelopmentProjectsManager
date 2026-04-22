import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/model/User.dart';
import 'package:frontend/provider/DeveloperModel.dart';
import 'package:frontend/view/ListTasksView.dart';
import 'package:frontend/view/signUpPage.dart';
import 'package:frontend/widget/HomePage.dart';
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
        case 201:
          onSuccess();
          break;
        case 400:
          showSnackBar(context, responseData['error'] ?? 'Bad Request');
          break;
        case 401:
          showSnackBar(context, 'Session expirée. Veuillez vous reconnecter.');
          break;
        case 403:
          showSnackBar(context, 'Accès interdit.');
          break;
        case 429:
          showSnackBar(
              context, 'Trop de tentatives. Réessayez dans quelques minutes.');
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
      print("User signed up with role: ${role.toString()}");

      http.Response res = await http.post(
        Uri.parse('${AppConfig.baseUrl}/users'),
        body: jsonEncode(user.toMap()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(AppConfig.requestTimeout);

      if (!context.mounted) return;
      //debugging
      print("Backend response during signup: ${res.body}");

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          // Debugging: Confirm the signup succeeded
          print(
              "Signup successful for user: $name with role: ${role.toString()}");
          showSnackBar(
            context,
            'Compte créé ! Connectez-vous avec vos identifiants.',
          );
          final prefs = await SharedPreferences.getInstance();
          final refreshToken = res.headers['x-refresh-token'] ?? '';
          final accessToken = res.headers['x-access-token'] ?? '';

          await prefs.setString('x-refresh-token', refreshToken);
          await prefs.setString('x-access-token', accessToken);
        },
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context,
            'Impossible de contacter le serveur. Vérifiez votre connexion.');
      }
    }
  }

  void LogInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        showSnackBar(context, 'Veuillez remplir tous les champs.');
        return;
      }
      print(
          "Attempting to log in with email: $email and password: $password"); // Debugging line
      var userProvider = Provider.of<DeveloperModel>(context, listen: false);
      final navigator = Navigator.of(context);
      http.Response res = await http.post(
        Uri.parse('${AppConfig.baseUrl}/users/login'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(AppConfig.requestTimeout);

      if (!context.mounted) return;
      print("Server response: ${res.statusCode} ${res.body}"); // Debugging line

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          //final responseData = jsonDecode(res.body);
          userProvider.setUser(res.body);

          print(
              "User logged in with role: ${userProvider.user.role.toString()}");

          final accessToken = res.headers['x-access-token'] ?? '';
          final responseBody = jsonDecode(res.body);
          final token = responseBody['token'];
          final refreshToken = res.headers['x-refresh-token'] ?? '';

          if (token == null || refreshToken.isEmpty) {
            throw Exception('Failed to get tokens from login response.');
          }

          print("Access Token: $token");
          print("Refresh Token: $refreshToken");
          //await prefs.setString('x-access-token', responseData['token']);
          await prefs.setString(
              'x-refresh-token', res.headers['x-refresh-token'] ?? '');
          await prefs.setString('x-access-token', token);
          await saveTokens(token, refreshToken);

          String userRole = userProvider.user.role.toString();
          print("User logged in with role: $userRole");

          if (userRole == 'Role.Administrator') {
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomePage(user: userProvider.user)),
              (route) => false,
            );
          } else {
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ListTasksView()),
              (route) => false,
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context,
            'Impossible de contacter le serveur. Vérifiez votre connexion.');
      }
    }
  }

  void signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('x-access-token');
    await prefs.remove('x-refresh-token');
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
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
    String? accessToken = prefs.getString('x-access-token');
    String? refreshToken = prefs.getString('x-refresh-token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('No access token found');
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token found');
    }
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
    await prefs.setString('x-access-token', accessToken);
    await prefs.setString('x-refresh-token', refreshToken);
  }

  // Function to clear tokens
  static Future<void> clearTokens() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('x-access-token');
    await prefs.remove('x-refresh-token');
  }
}
