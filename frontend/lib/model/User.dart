
import 'package:flutter/material.dart';

enum Role {
  Developer,
  Manager,
  Administrator,
}

class User  extends ChangeNotifier {
   String idUtilisateur;
   String nomUtilisateur;
   String email;
   String motDePasse;
   Role role;
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUtilisateur: json['userId'],
      nomUtilisateur: json['name'],
      email: json['email'],
      motDePasse: json['password'],
      role: Role.values[json['role']],  // Assuming role is passed as an index
    );
  }
}
