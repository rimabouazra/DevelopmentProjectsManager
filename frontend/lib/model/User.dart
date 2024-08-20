
import 'package:flutter/material.dart';

enum Role {
  Developer,
  Manager,
  Administrator,
}

class User  extends ChangeNotifier {
  final String idUtilisateur;
  final String nomUtilisateur;
  final String email;
  final String motDePasse;
  final Role role;
  User? currentUser;

  User({
    required this.idUtilisateur,
    required this.nomUtilisateur,
    required this.email,
    required this.motDePasse,
    required this.role,
  });

  bool canCreateProject() {
    return role == Role.Manager;
  }

  bool canManageUsers() {
    return role == Role.Administrator;
  }

  bool canModifyProject() {
    return role == Role.Manager || role == Role.Administrator;
  }
}
