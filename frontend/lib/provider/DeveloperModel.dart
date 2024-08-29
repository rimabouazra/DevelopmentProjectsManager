import 'dart:convert';

import 'package:flutter/material.dart';
import '../model/User.dart';
import 'package:http/http.dart' as http;


class DeveloperModel extends ChangeNotifier {
  User _user =User(
    idUtilisateur: '',
    nomUtilisateur: '',
    email: '',
    token: '',
    motDePasse: '',
    role: Role.Developer,
  );

  User get user => _user;

   List<User> _developers = [];

  List<User> get developers => _developers;

  void setUser(String userJson) {
  var userMap = json.decode(userJson);
  _user = User.fromJson(userMap);
  notifyListeners();
}

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> fetchDevelopers() async {
  final response = await http.get(Uri.parse('http://localhost:3000/developers'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List<dynamic>;
    _developers = data
        .map((json) => User.fromJson(json))
        .where((user) => user.role == Role.Developer)
        .toList();
    notifyListeners();
  } else {
    throw Exception('Failed to load developers');
  }
}

}
