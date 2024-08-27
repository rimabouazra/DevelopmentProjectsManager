
import 'dart:convert';

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
   final String token;
   String motDePasse;
   Role role;
  User? currentUser;

  User({
    required this.idUtilisateur,
    required this.nomUtilisateur,
    required this.email,
    required this.token,
    required this.motDePasse,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': nomUtilisateur,
      'email': email,
      'token': token,
      'password': motDePasse,
      'role': role.index,
    };
  }

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
      idUtilisateur: json['_Id'],
      nomUtilisateur: json['name'],
      email: json['email'],
      token: json['token'] ?? '',
      motDePasse: json['password'],
      role: Role.values[json['role']],
    );
  }

  String toJson() => json.encode(toMap());
}
