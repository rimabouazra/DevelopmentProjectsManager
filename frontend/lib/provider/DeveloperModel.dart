import 'package:flutter/material.dart';
import '../model/User.dart';

class DeveloperModel extends ChangeNotifier {
  final List<User> developers = [];

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
