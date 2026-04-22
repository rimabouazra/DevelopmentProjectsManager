import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/model/User.dart';
import 'package:http/http.dart' as http;

class DeveloperModel extends ChangeNotifier {
  User _user = User(
    idUtilisateur: '',
    nomUtilisateur: '',
    email: '',
    token: '',
    motDePasse: '',
    role: Role.Developer,
  );

  List<User> _developers = [];
  List<User> _managers = [];

  User get user => _user;
  List<User> get developers => _developers;
  List<User> get managers => _managers;

  // Définir l'utilisateur connecté 
  void setUser(String userJson) {
    try {
      final userMap = json.decode(userJson);
      if (userMap.containsKey('user')) {
        _user = User.fromJson(userMap['user']);
        notifyListeners();
      } else {
        print('Clé "user" absente dans la réponse JSON');
      }
    } catch (e) {
      print('Erreur lors du parsing de l\'utilisateur: $e');
    }
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

  // Récupérer les développeurs 
  Future<void> fetchDevelopers() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/developers'))
          .timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        _developers = data
            .map((j) => User.fromJson(j))
            .where((u) => u.role == Role.Developer)
            .toList();
        notifyListeners();
      } else {
        throw Exception('Erreur lors du chargement des développeurs');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Récupérer les managers
  Future<void> fetchManagers() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/managers'))
          .timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        _managers = data.map((j) => User.fromJson(j)).toList();
        notifyListeners();
      } else {
        throw Exception('Erreur lors du chargement des managers');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}