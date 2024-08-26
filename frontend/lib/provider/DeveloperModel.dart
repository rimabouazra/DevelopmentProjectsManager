import 'package:flutter/material.dart';
import '../model/User.dart';

class DeveloperModel extends ChangeNotifier {
  final List<User> developers = [
    User(
    idUtilisateur: '1',
    nomUtilisateur: 'DevUser',
    email: 'dev@example.com',
    motDePasse: 'password123',
    role: Role.Developer,
  ),
  User(
    idUtilisateur: '3',
    nomUtilisateur: 'AdminUser',
    email: 'admin@example.com',
    motDePasse: 'password123',
    role: Role.Administrator,
  )
  ];

  List<User> getDevelopers() {
    return developers.where((user) => user.role == 'Developer').toList();
  }

  void addDeveloper(User developer) {
    developers.add(developer);
    notifyListeners();
  }

  void removeDeveloper(String developerId) {
    developers.removeWhere((dev) => dev.idUtilisateur == developerId);
    notifyListeners();
  }
}
